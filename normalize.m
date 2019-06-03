%%Batch processing for normalization
%%@Author: Cristina Perez Diukina
%%@Day: 4/5/2019
%%@Description: normalizes all ur_ imafes and writes them 
%% in FUNCTIONAL folder
%% Prepares for smoothing

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
thissubj = param(1).name

for s = 2:length(param)
      %%go back to preprocess for every subject
     cd(preprocess)
     %%load batch from manually preprocessed subject
     load SPM_norm.mat
     
     %%define directories
     dir_anat = fullfile(data,param(s).name,'ANATOMICAL');
     dir_func = fullfile(data,param(s).name,'FUNCTIONAL');
     
     %%find MPRAGE_SkullStrpping/ ANATOMICAL
      %%select the reference image (skulltripped anatomical)/ANATOMICAL
%     [skullS, ~] = spm_select('List', dir_anat,'^MPRAGE_SkullStripping.nii');
    [skullS, ~] = spm_select('List', dir_anat,'^MPRAGE.nii');
    skullS = cellstr([dir_anat filesep skullS]);
        %load it into spm
     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = skullS;
     
     %%select all u*studyname*_run# /FUNCTIONAL
     %%weird implementation because otherwise vectors can't concat
    %%diff min
    [u, ~] = spm_select('List', dir_func,'^urhythm_run');
    numTRs = length(u);
        u = [repmat([dir_func filesep],numTRs,1), u];
        u = cellstr(u);
     
     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample=u;
     
     %%Save Batch 
    filename = fullfile(data, param(s).name, 'batch', 'norm.mat');
    save(filename, 'matlabbatch')
            %%Run batch
    spm_jobman('run', matlabbatch)
    
    
    
    
    
    
    
end