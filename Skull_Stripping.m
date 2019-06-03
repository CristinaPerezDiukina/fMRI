%%Batch processing for corregister
%%@Author: Cristina Perez Diukina
%%@Day: 4/2/2019
%%@Description: Performs brain extraction on all subjects saved
%%in param and saves new anatomical picture MPRAG_SkullStripping in
%% Anatomical folder
%% Prepares for coregistration

            %% NOTES %%
% values in *_* are dependant on the study
% / is followed by the folder where files are located
close all
preprocess = pwd;

cd ..
rhythm_param

cd ..
cd data
data = pwd;

spm('defaults', 'FMRI');
spm_jobman('initcfg')
spm_figure('GetWin','Graphics');

for s = 2:length(param)
     %%go back to preprocess for every subject
     cd(preprocess)
     %%load batch from manually preprocessed subject
     load SPM_anatomical.mat
     
     
             %%Segment
    dir_anat = fullfile(data,param(s).name,'ANATOMICAL');
     cd(dir_anat);
     [MPRAGE, ~] = spm_select('List', dir_anat, 'MPRAGE.nii');
     MPRAGE = cellstr([dir_anat filesep MPRAGE]);
     
     
     
     matlabbatch{1}.spm.spatial.preproc.channel.vols = MPRAGE;
     
             %%Save batch
     filename = fullfile(data, param(s).name, 'batch', 'anatomical.mat');
    save(filename, 'matlabbatch')
            %%Run batch
     spm_jobman('run', matlabbatch)
    
    
            %%Skull Stripping
            
    %%go back to preprocess for every subject
    cd(preprocess)
    %%load batch from manually preprocessed subject
    load SPM_SkullStripping.mat
    
    
    [c1MPRAGE, ~] = spm_select('List', dir_anat, 'c1MPRAGE.nii');
      c1MPRAGE = cellstr([dir_anat filesep c1MPRAGE]);
    matlabbatch{1}.spm.util.imcalc.input(1) = c1MPRAGE;
    
    [c2MPRAGE, ~] = spm_select('List', dir_anat, 'c2MPRAGE.nii');
      c2MPRAGE = cellstr([dir_anat filesep c2MPRAGE]);
    matlabbatch{1}.spm.util.imcalc.input(2) = c2MPRAGE;
    
    %%not sure if segmentation changed MPRAGe, might be useless step
    [MPRAGE, ~] = spm_select('List', dir_anat, '^MPRAGE.nii');
      MPRAGE = cellstr([dir_anat filesep MPRAGE]);
      matlabbatch{1}.spm.util.imcalc.input(3) = MPRAGE;
      
      C = cellstr(dir_anat);
      matlabbatch{1}.spm.util.imcalc.outdir = C;
      
       %%Save batch
    filename = fullfile(data, param(s).name, 'batch', 'SkullStripping.mat');
    save(filename, 'matlabbatch')
            %%Run batch
    spm_jobman('run', matlabbatch)
    
    
    
end