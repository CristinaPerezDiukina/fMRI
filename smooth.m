%%Batch processing for smoothing
%%@Author: Cristina Perez Diukina
%%@Day: 4/5/2019
%%@Description: smoothes all wur_ images and writes them as swu
%% in FUNCTIONAL folder


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
     load SPM_smooth.mat
     
     %%define directories
    
     dir_func = fullfile(data,param(s).name,'FUNCTIONAL');
     
     
     
     %%select all wu*studyname*_run# /FUNCTIONAL
     %%weird implementation because otherwise vectors can't concat
    %%diff min
    [u, ~] = spm_select('List', dir_func,'^wurhythm_run');
    numTRs = length(u);
        u = [repmat([dir_func filesep],numTRs,1), u];
        u = cellstr(u);
     
     matlabbatch{1}.spm.spatial.smooth.data = u;
     
     %%Save Batch 
    filename = fullfile(data, param(s).name, 'batch', 'smooth.mat');
    save(filename, 'matlabbatch')
            %%Run batch
    spm_jobman('run', matlabbatch)
    
    
    
    
    
    
    
end