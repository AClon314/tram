#! /usr/bin/env -S conda run --live-stream -n tram python
import os
import argparse
import subprocess

class CustomArgumentParser(argparse.ArgumentParser):
    def print_help(self, file=None):
        super().print_help(file)
        for py in os.listdir('scripts'):
            if py.endswith('.py') and py != 'run.py':
                subprocess.run(['python',f'scripts/{py}.py','--help'])

parser = CustomArgumentParser()
parser.add_argument('--video', type=str, default='./example_video.mov', help='input video')

args = parser.parse_args()

video = os.path.abspath(args.video)
os.makedirs(f'results',exist_ok=True)
cwd=os.getcwd()+'/results'
os.chdir(os.path.dirname(os.path.abspath(__file__)))
subprocess.run(['ln','-s',cwd,f'results'])

pys = ['estimate_camera','estimate_humans','visualize_tram']
for py in pys:
    ret = subprocess.run(['python',f'scripts/{py}.py','--video',video]).returncode
    if ret != 0:
        exit(1)

os.chdir(f'{cwd}/{os.path.basename(video).split(".")[0]}')
ret = subprocess.run([f"tar -czvf {video}.tar.gz --exclude='./images' --exclude='./Annotations' --exclude='./tram_output.mp4' ./*"]).returncode
