
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
    cd(preprocess)
    load SPM_realign_unwarp.mat
    dir_func = fullfile(data,param(s).name,'FUNCTIONAL');
    dir_vdm= fullfile(data,param(s).name, 'realign');
    dir_reg = fullfile(data,param(s).name, 'reg');
    dir_ps = fullfile(data, param(s).name, 'ps', 'preproc');
    
    cd(dir_func)

    for r = 1:param(s).runs
        [boldFiles, ~] = spm_select('List', dir_func, ['^rhythm_run' num2str(r) '_00*.*\.nii$']);
        numTRs = length(boldFiles);
        boldFiles = [repmat([dir_func filesep],numTRs,1), boldFiles];
        boldFiles = cellstr(boldFiles);
        matlabbatch{1}.spm.spatial.realignunwarp.data(r).scans = boldFiles;
       
        [vdmFiles, ~] = spm_select('List', dir_vdm, '^vdm5_*.*\.nii$');
        vdmFiles = cellstr([dir_vdm filesep vdmFiles]);
        matlabbatch{1}.spm.spatial.realignunwarp.data(r).pmscan = vdmFiles;
    end
    
    if param(s).runs == 1
        matlabbatch{1}.spm.spatial.realignunwarp.data(2) = [];
    end
    
    filename = fullfile(data, param(s).name, 'batch', 'realign_unwarp.mat');
    save(filename, 'matlabbatch')
    
    spm_jobman('run', matlabbatch)
    
   	filename = fullfile(dir_func, 'rp_*');
    movefile(filename, dir_reg);
    
    psfile = date;
    psfile = [psfile(8:end) psfile(4:6) psfile(1:2)];
    psfile = fullfile(dir_func, ['spm_', psfile '*.pdf']);
    movefile(psfile, fullfile(dir_ps, 'realign_unwarp.pdf'));
    
end
