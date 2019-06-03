%%Batch processing for coregister
%%@Author: Cristina Perez Diukina
%%@Day: 4/3/2019
%%@Description: Implements coregistration on all subjects saved
%%in param cell and writes ur files in Functional folder
%% prepapres for normalization


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
    load SPM_coregister.mat
   
    
    dir_anat = fullfile(data,param(s).name,'ANATOMICAL');
    dir_func = fullfile(data,param(s).name,'FUNCTIONAL');
    
    
    %%select the reference image (skulltripped anatomical)/from ANATOMICAL
%     [skullS, ~] = spm_select('List', dir_anat,'^MPRAGE_SkullStripping.nii');
    [skullS, ~] = spm_select('List', dir_anat,'^MPRAGE.nii');
    skullS = cellstr([dir_anat filesep skullS]);
        %load it into spm
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = skullS;
    
    
    %%select the other images ((all u*studyname_run*#*))/from FUNCTIONAL
    
    
    %%weird implementation because otherwise vectors can't concat
    %%diff min
    [u, ~] = spm_select('List', dir_func,'^urhythm_run');
    numTRs = length(u);
        u = [repmat([dir_func filesep],numTRs,1), u];
        u = cellstr(u);
   
    
    %%load into spm
    matlabbatch{1}.spm.spatial.coreg.estimate.other = u;
    
    
    
       
    
    %%select the source image (*studyname*_run1_SBRef) /from FUNCTIONAL
    [SBRef, ~] = spm_select('List', dir_func,'^rhythm_run1_SBRef');
    SBRef = cellstr([dir_func filesep SBRef]);
    %%load it into spm
    matlabbatch{1}.spm.spatial.coreg.estimate.source = SBRef;
    
    %%Save Batch 
    filename = fullfile(data, param(s).name, 'batch', 'coregister.mat');
    save(filename, 'matlabbatch')
            %%Run batch
    spm_jobman('run', matlabbatch)
    
    
    
    
    
    
    
    
end