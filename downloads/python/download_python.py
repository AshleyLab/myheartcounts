import synapseclient 
import argparse 
import shutil 

import pdb 

def parse_args(): 
    parser=argparse.ArgumentParser(description="Arguments for data download") 
    parser.add_argument("--start_date",default=None) 
    parser.add_argument("--end_date",default=None) 
    parser.add_argument("--tables",nargs="*",default=None) 
    parser.add_argument("--healthCodes",nargs="*",default=None) 
    parser.add_argument("--projectId",default="syn3270436")
    parser.add_argument("--table_dir",default="/oak/stanford/groups/euan/projects/mhc/data/tables")
    parser.add_argument("--synapseCache",default="/oak/stanford/groups/euan/projects/mch/data/synapseCache")
    parser.add_argument("--tables_only",action="store_true",default=False) 
    parser.add_argument("--blobs_only",action="store_true",default=False) 
    return parser.parse_args() 

def build_query(table_id,args): 
    query="SELECT * from "+table_id
    if args.start_date is not None: 
        query=query+" WHERE createdOn >= '"+args.start_date+"'"
    if args.end_date is not None: 
        if query.endswith(table_id): 
            query=query+" WHERE createdOn <= '"+args.end_date+"'"
        else: 
            query=query+" AND createdOn <= '"+args.end_date+"'"
    if args.healthCodes is not None: 
        if query.endswith(table_id): 
            query=query+ " WHERE healthCode in "+str(tuple(args.healthCodes))
        else: 
            query=query+" AND  healthCode in "+str(tuple(args.healthCodes))
    print(query) 
    return query 

def get_tables_to_query(syn,args):
    table_dict={} 
    project_tables=syn.getChildren(args.projectId,includeTypes=['table','file'])
    for table in project_tables: 
        table_id=table['id']
        table_name=table['name'] 
        if args.tables is None or table_id in args.tables: 
            table_dict[table_id]=table_name 
    return table_dict 

def main(): 
    args=parse_args() 

    #create a synapseclient instance 
    syn=synapseclient.Synapse() 

    #login 
    syn.login() 
    
    #get tables to query -- returns a dictionary {table_id --> table_name} 
    tables_to_query=get_tables_to_query(syn,args)
    
    for table_id in tables_to_query:
        table_name=tables_to_query[table_id]
        #build the query
        query=build_query(table_id,args)

        #perform query 
        try:
            response=syn.tableQuery(query,resultsAs='csv',separator='\t')
            print("downloaded table:"+table_name)
        except Exception as e: 
            print(e) 
            print("SKIPPING:"+str(table_name))
            continue 

        if args.tables_only is False: 
            #identify FILEHANDLEID columns to pull down 
            columns_to_download=[] 
            for header in response.headers: 
                if header['columnType']=="FILEHANDLEID": 
                    columns_to_download.append(header['name'])

            #download table FILEHANDLEID columns 
            print("downloading columns:"+str(columns_to_download))
            files=syn.downloadTableColumns(response,columns_to_download)
        
        if args.blobs_only is False: 
            #move table to appropriate location 
            cur_table_path="/".join([args.table_dir,table_name+".tsv"])
            shutil.move(response.filepath,cur_table_path)

    
if __name__=="__main__": 
    main() 
