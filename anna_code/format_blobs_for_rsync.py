#formats blob names for rsync
data=open('synapseCache.tocopy').read().strip().split('\n')
outf=open('synapseCache.tmp','w')
for line in data:
    if line=="NA":
        continue
    outer_dir=line[-3::]
    while outer_dir.startswith('0'):
        outer_dir=outer_dir[1::]
    if len(outer_dir)==0:
        outer_dir='0'
    outf.write(outer_dir+'/'+line+'\n')
    
