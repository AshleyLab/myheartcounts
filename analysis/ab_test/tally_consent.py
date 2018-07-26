#tally up the number of subjects who have agreed to share data with researchers, other parties, and "NA"
import argparse
import pdb
def parse_args():
    parser=argparse.ArgumentParser(description="tally  up the number of subjects who have agreed to share data with researchers, other parties, or  have entered \"NA\"")
    parser.add_argument("--ab_test_table")
    parser.add_argument("--outf")
    return parser.parse_args()

def main():
    args=parse_args() 
    data=open(args.ab_test_table,'r').read().strip().split('\n')
    healthCode_to_userSharingScope=dict()
    header=data[0].split('\t')
    healthCode_index=header.index("healthCode")+1
    userSharingScope_index=header.index("userSharingScope")+1
    for line in data[1::]:
        tokens=line.split('\t')
        healthCode=tokens[healthCode_index]
        userSharingScope=tokens[userSharingScope_index]
        if healthCode not in healthCode_to_userSharingScope:
            healthCode_to_userSharingScope[healthCode]=[userSharingScope]
        else:
            healthCode_to_userSharingScope[healthCode].append(userSharingScope)
    outf=open(args.outf,'w')
    #some users may have multiple entries -- record the one that offers broadest consent
    for subject in healthCode_to_userSharingScope:
        scope_entries=healthCode_to_userSharingScope[subject]
        if 'ALL_QUALIFIED_RESEARCHERS' in scope_entries:
            outf.write(subject+'\t'+'ALL_QUALIFIED_RESEARCHERS\n')
        elif 'SPONSORS_AND_PARTNERS' in scope_entries:
            outf.write(subject+'\t'+'SPONSORS_AND_PARTNERS\n')
        else:
            outf.write(subject+'\t'+'\t'.join(scope_entries)+'\n')

if __name__=="__main__":
    main() 
