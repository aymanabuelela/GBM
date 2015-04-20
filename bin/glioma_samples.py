### Script to extract SRA files for primary and SECONDARY GLIOMA
lines = [ line.strip().strip('"').split('\t') for line in open('GSE48865_series_matrix.txt').readlines() ]
hist = [ line for line in lines if "!Sample_characteristics_ch1" in line[0] ][0][1:] 
sample_title = [ line for line in lines if "!Sample_title" in line [0] ][0][1:]
geo_accession = [ line for line in lines if "!Sample_geo_accession" in line [0] ][0][1:]
#idh
srr = [ 'SRR'+str(num+934717)+'.sra' for num in range(274) ]

histall = []
pri_sec = []
#idh_wt =
#idh_m = 
metadata = zip(hist, sample_title, geo_accession)

dic = dict(zip(srr, metadata))

for srr, meta in dic.items():
    histall.append(srr+'\t'+'\t'.join(meta))
    if 'primary' in meta[0] or 'secondary' in meta[0]:
        pri_sec.append(srr+'\t'+'\t'.join(meta))

histallout = open('histall_glioma.txt', 'w')
histallout.write('\n'.join(histall)+'\n')

priout = open('primary_secondary_glioma.txt', 'w')
priout.write('\n'.join(pri_sec))
priout.write('\n')

priout.close()
histallout.close()
