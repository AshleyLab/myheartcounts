import pandas as pd 
import argparse 

def parse_args(): 
    parser=argparse.ArgumentParser(description="cumulative number of days with data for each subject/appVersion")
    parser.add_argument("--tables_to_parse",help="text file with full paths to all tables to include in parsing",default="table_paths.txt") 
    parser.add_argument("--outf",default="appVersion.tallies.txt") 
    return parser.parse_args()
 
def main():  
    args=parse_args() 

    #dictionary of healthCode->appVersion->uploadDate 
    data_hist=dict() 

    #prepare the output file 
    outf=open(args.outf,'w')
    outf.write('healthCode\tappVersion\tuploadDate\n')

    #iterate through each table 
    for table in open(args.tables_to_parse,'r').read().strip().split('\n'): 
        #load the data 
        try:
            data=pd.read_table(table,header=0,sep='\t')

            #make sure the 3 required fields are in the header, skip table if they are not 
            healthCodeInHeader='healthCode' in data.columns 
            uploadDateInHeader='uploadDate' in data.columns 
            appVersionInHeader='appVersion' in data.columns 
            fileHasAllFields=healthCodeInHeader and uploadDateInHeader and appVersionInHeader 
            if (fileHasAllFields==False): 
                print("File"+table+" does not have required healthCode, appVersion, uploadDate fields. Skipping") 
                continue 
        except: 
            print("could not open table:"+str(table)+" for parsing. Skipping.")
            continue 

        #iterate through each row; store healthCode->appVersion->uploadDate mapping 
        for index,row in data.iterrows():  
            healthCode=row['healthCode'] 
            uploadDate=row['uploadDate']
            appVersion=row['appVersion'] 
            if healthCode not in data_hist: 
                data_hist[healthCode]=dict() 
            if appVersion not in data_hist[healthCode]: 
                data_hist[healthCode][appVersion]={uploadDate:1}
            else: 
                data_hist[healthCode][appVersion][uploadDate]=1 
        print("Finishing parsing table:"+str(table))

    print("Finished parsing all tables. Writing data_hist to ouptut file")
    for healthCode in data_hist: 
        for appVersion in data_hist[healthCode]: 
            for uploadDate in data_hist[healthCode][appVersion]: 
                outf.write('\t'.join([str(healthCode),str(appVersion),str(uploadDate)])+'\n')
        

if __name__=="__main__": 
    main() 
