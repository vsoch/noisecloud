% noisecloud_setup

global atlas gm_map wm_map csf_map edges_map midbrain_map eyeballs_map skull_map ventricles_map cerebellum_map cord_map

% EDIT THESE PATHS: ATLASES AND MATTER TYPE MAPS
% The following images MUST BE in standard space, with equal dimensions as the functional data.'
atlas = ('mr/your_aal2mni152.nii');  % This is the aal atlas, but you can use an atlas of your choice
gm_map = ('mr/your_grey.nii');
wm_map = ('mr/your_white.nii');
csf_map = ('mr/your_csf.nii');
edges_map = ('mr/your_MNI152_T1_2mm_edges.nii');
midbrain_map = ('mr/your_MNI152_T1_3mm_strucseg.nii');  % Ventricles: 5
% Has intensities 0 to 5                                % Dorsal Cerebellum: 3
                                                        % Midbrain: 4
                                                        % Cord: 2
                                                        % Ventral Cerebellum: 
                                                        % Rest Brain: 1
eyeballs_map = ('mr/your_MNI152_T1_3mm_eye_mask.nii');
skull_map = ('mr/your_MNI152_T1_3mm_skull.nii');







% DO NOT EDIT BELOW THIS LINE ---------------------------------------------

% Check to make sure the atlases exist
if ~exist(atlas) || ~exist(wm_map) || ~exist(gm_map) || ~exist(csf_map) || ~exist(edges_map) || ~exist(midbrain_map) || ~exist(eyeballs_map) || ~exist(skull_map)
    error('Cannot find your registered atlas images in folder mr!  Did you register the maps to your data, and enter paths in noisecloud_setup.m?');
end

fprintf('%s\n','Reading in spatial tissue maps and atlases...');

% MAPS REQUIRED FOR SPATIAL FEATURE EXTRACTION 
% Use spm_read_vols and spm_vol to get actual data!
atlas = spm_read_vols(spm_vol(atlas));
wm_map = spm_read_vols(spm_vol(wm_map));
gm_map = spm_read_vols(spm_vol(gm_map));
csf_map = spm_read_vols(spm_vol(csf_map));
edges_map = spm_read_vols(spm_vol(edges_map));
midbrain_map = spm_read_vols(spm_vol(midbrain_map));
eyeballs_map = spm_read_vols(spm_vol(eyeballs_map));
skull_map = spm_read_vols(spm_vol(skull_map));

% Break midbrain map into atlases for different components
ventricles_map = midbrain_map == 5; % Ventricles: 5
cerebellum_map = midbrain_map == 3; % Cerebellum: 3
cord_map = midbrain_map == 2;       % Cord: 2
midbrain_map = midbrain_map == 4;   % Midbrain: 4

