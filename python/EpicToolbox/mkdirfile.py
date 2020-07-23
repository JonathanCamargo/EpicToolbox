import os

def mkdirfile(outfile):
    outfolder,_=os.path.split(outfile)
    os.makedirs(outfolder,exist_ok=True)
