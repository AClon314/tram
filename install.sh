set -x
# mamba remove -n tram --all -y
# mamba create -n tram python=3.10 -y
# mamba activate tram

# mamba install nvidia/label/cuda-11.8.0::cuda-toolkit -y # you can disable this if you already have cuda-11.8
mamba install pytorch==2.0.0 torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia -y
pip install 'git+https://github.com/facebookresearch/detectron2.git@a59f05630a8f205756064244bf5beb8661f96180'
pip install "git+https://github.com/facebookresearch/pytorch3d.git@stable"

mamba install -c pyg pytorch-scatter=2.1.2=py310_torch_2.0.0_cu118
mamba install -c conda-forge suitesparse

pip install pulp
pip install supervision

pip install open3d
pip install opencv-python
pip install loguru
pip install chumpy
pip install einops
pip install plyfile
pip install pyrender
pip install segment_anything
pip install scikit-image
pip install smplx
pip install timm==0.6.7
pip install evo
pip install pytorch-minimize
pip install imageio[ffmpeg]
pip install numpy==1.23
pip install gdown

