from torch.utils.data import Dataset,DataLoader

class DataframesDataset(Dataset):
    def __init__(self,datax,datay,xfields=None,yfields=None):
        ''' Create a dataset from the information contained
        in a pandas dataframe'''
        self.x=datax
        self.y=datay
        self.xfields=xfields
        self.yfields=yfields
        if xfields==None:
            self.xfields=self.x.columns.to_list()
        if yfields==None:
            self.yfields=self.y.columns.to_list()            
        
    def __len__(self):
        return self.x.shape[0]
    
    def __getitem__(self,i):
        x=self.x.loc[i,[*self.xfields]].to_numpy()
        y=self.x.loc[i,[*self.yfields]].to_numpy()
        return x,y
