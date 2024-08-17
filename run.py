#! /usr/bin/env -S conda run --live-stream -n tram python
"""
Run TRAM pipeline
"""
import os
import sys
import argparse
import subprocess

class CustomArgumentParser(argparse.ArgumentParser):
    """
    显示所有scripts的帮助
    """
    def print_help(self, file=None):
        super().print_help(file)
        for _py in os.listdir('scripts'):
            if _py.endswith('.py') and py != 'run.py':
                subprocess.run(['python',f'scripts/{py}.py','--help'],check=True)

parser = CustomArgumentParser()
parser.add_argument('--video', type=str, default='./example_video.mov', help='input video')

args = parser.parse_args()

video_path = os.path.abspath(args.video)
video_name = os.path.basename(video_path).split('.')[0]
os.makedirs('results',exist_ok=True)
results_path=os.getcwd()+'/results'
os.chdir(os.path.dirname(os.path.abspath(__file__)))
if not os.path.exists('results'):
    os.symlink(results_path,'results')

pys = [['estimate_camera','tracks.npy'],['estimate_humans','hps'],['visualize_tram']]
for py in pys:
    if len(py)>1 and os.path.exists(f'{results_path}/{video_name}/{py[1]}'):
        continue
    ret = subprocess.run(['python',f'scripts/{py[0]}.py','--video',video_path],check=True).returncode
    if ret != 0:
        sys.exit()

os.chdir(f'{results_path}/{video_name}')
ret = subprocess.run([f"tar -czvf {video_path}.tar.gz --exclude='./images' --exclude='./Annotations' --exclude='./tram_output.mp4' ./*"],check=True).returncode
