# Derive dashboard dataset from the master store (+ enquiries). Preserves URLs already in master.
import json, os
PEOPLE={'Harsh','Dubey','Gagan','Saurabh'}
master=json.load(open('ranking_data.json'))
dates=master['dates']; groups={}
def nb(): return {'b3':0,'b4_10':0,'b11_30':0,'b31_50':0,'b50':0,'b_oth':0,'total':0,'live':0,'notlive':0,'newlive':0}
kw_rows=[]
for rec in master['kw'].values():
    grp=rec['grp']
    if grp not in groups: groups[grp]={'isPerson':grp in PEOPLE,'series':[nb() for _ in dates]}
    series=groups[grp]['series']; prev_live=None
    for i,v in enumerate(rec['r']):
        s=series[i]; s['total']+=1
        if v is None: s['notlive']+=1
        else:
            s['live']+=1
            if v=='-': s['b50']+=1; s['b_oth']+=1
            elif v<=3: s['b3']+=1
            elif v<=10: s['b4_10']+=1
            elif v<=30: s['b11_30']+=1
            elif v<=50: s['b31_50']+=1
            else: s['b50']+=1; s['b_oth']+=1
            if prev_live is False: s['newlive']+=1
        prev_live=(v is not None)
    def num(x): return x if isinstance(x,int) else None
    lst=num(rec['r'][-1]); prv=num(rec['r'][-2]) if len(rec['r'])>=2 else None
    lr=rec['r'][-1]; pr=rec['r'][-2] if len(rec['r'])>=2 else None
    if lr is None: st='notlive'
    elif pr is None and lr is not None: st='new'
    elif lst is not None and prv is not None: st='up' if lst<prv else ('down' if lst>prv else 'same')
    elif lst is not None and prv is None: st='up'
    elif lst is None and prv is not None: st='down'
    else: st='same'
    chg=(prv-lst) if (lst is not None and prv is not None) else None
    kw_rows.append({'kw':rec['kw'],'grp':grp,'r':rec['r'],'searches':rec['searches'],'url':rec['url'],'chg':chg,'st':st})

out={'dates':dates,'groups':groups,'people':sorted(PEOPLE),'kw':kw_rows}
if os.path.exists('enquiries_data.json'):
    out['enq']=json.load(open('enquiries_data.json'))
json.dump(out, open('data4.json','w'), default=str)
print('data4.json', os.path.getsize('data4.json'), '| enq included:', 'enq' in out)
