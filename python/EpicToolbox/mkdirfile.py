import os

def mkdirfile(outfile):
    outfolder,outextension=os.path.splitext(outfile)
    if outextension=='':
        os.makedirs(outfolder,exist_ok=True)
    else:
        outfolder,_=os.path.split(outfolder)
        os.makedirs(outfolder,exist_ok=True)
