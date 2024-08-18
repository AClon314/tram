import argparse
import sys
import os
from glob import glob

sys.path.insert(0, os.path.dirname(__file__) + '/..')

parser = argparse.ArgumentParser()
parser.add_argument("--video", type=str, default='./example_video.mov',
                    help='gernerated folder of input video')
parser.add_argument('--ground_estimate', type=int, default=[10, -10], nargs='+',
                    help='Frist/last N frames to estiamte ground. Set to 0 to use all frames.')
args = parser.parse_args()

import numpy as np
from lib.pipeline.export import export_tram

# File and folders
video = args.video
root = os.path.dirname(video)
seq = os.path.basename(video).split('.')[0]
seq_folder = f'results/{seq}'
hps_folder = f'{seq_folder}/hps'
output_dir = f'{seq_folder}/gltf'
img_folder = f'{seq_folder}/images'
imgfiles = sorted(glob(f'{img_folder}/*.jpg'))
_ = os.mkdir(output_dir) if not os.path.exists(output_dir) else None

##### Combine camera & human motion #####
# Set the frame to estimate the ground plane
if args.ground_estimate[0] == 0 :
    contact_frames = np.arange(len(imgfiles))
else:
    idx = np.concatenate([np.arange(args.ground_estimate[0]), 
                          np.arange(args.ground_estimate[1],0)])  
    contact_frames = np.arange(len(imgfiles))[idx]

# Export
print('Exporting')
export_tram(seq_folder, contact_frames=contact_frames)