import json
MODULE = 'seurat'

mi_template_json = {'module_version': '00.00.02', 'program_name': 'seurat', 'program_subname': '', 'program_version': '4.0.6', 'compute': {'environment': 'aws', 'language': 'Python', 'language_version': '3.7', 'vcpus': 4, 'memory': 28000}, 'program_arguments': '', 'program_input': [{'input_type': 'folder', 'input_file_type': '', 'input_position': -1, 'input_prefix': '-i'}], 'program_output': [{'output_type': 'folder', 'output_file_type': '', 'output_position': -100, 'output_prefix': ''}], 'alternate_inputs': [], 'alternate_outputs': [], 'defaults': {"output_file": ""}}
with open(MODULE+'.template.json','w') as fout:
    json.dump(mi_template_json, fout)

io_json = {'input': ['s3://hubtenants/test/singlecell_rnaseq/run_test1/cellranger/filtered_gene_bc_matrices/hg19/'], 'output': ['s3://hubtenants/test/singlecell_rnaseq/run_test1/seurat/'],  'alternate_inputs': [], 'alternate_outputs': [], 'program_arguments': '', 'sample_id': MODULE+'_test'}
with open(MODULE+'.test.io.json','w') as fout:
    json.dump(io_json, fout)

io_json2 = {'input': ['s3://hubtenants/test/singlecell_rnaseq/run_test1/cellranger/filtered_gene_bc_matrices/hg19/'], 'output': ['s3://hubtenants/test/singlecell_rnaseq/run_test1/seurat/'],  'alternate_inputs': [], 'alternate_outputs': [], 'program_arguments': '-qconly', 'sample_id': MODULE+'_test'}
with open(MODULE+'.test.io2.json','w') as fout:
    json.dump(io_json2, fout)    

io_dryrun_json = io_json
io_dryrun_json['dryrun'] = ''
with open(MODULE+'.dryrun_test.io.json','w') as fout:
    json.dump(io_dryrun_json, fout)

# job info test JSONs                                                                                                        
job_json = {"container_overrides": {"command": ["--module_name", MODULE, "--run_arguments", "s3://hubseq-data/modules/"+MODULE+"/io/"+MODULE+".test.io.json", "--working_dir", "/home/"]}, "jobqueue": "batch_scratch_queue", "jobname": "job_"+MODULE+"_test"}
with open(MODULE+'.test.job.json','w') as fout:
    json.dump(job_json, fout)

job_json2 = {"container_overrides": {"command": ["--module_name", MODULE, "--run_arguments", "s3://hubseq-data/modules/"+MODULE+"/io/"+MODULE+".test.io2.json", "--working_dir", "/home/"]}, "jobqueue": "batch_scratch_queue", "jobname": "job_"+MODULE+"_test"}
with open(MODULE+'.test.job2.json','w') as fout:
    json.dump(job_json2, fout)    
