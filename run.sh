#!/bin/bash
if [[ "$1" == *"-h"* ]]; then
  echo "Usage: $0 <video_path> <img_focal_length>
   eg: $0 ./example_video.mov     # Auto detect focal length
   eg: $0 ./example_video.mov 600"
  exit 0
fi

trap "set +x && echo ❗ dont forgot: mamba activate tram" EXIT

[[ -n "$2" ]] && img_focal="--img_focal $2"
vd="$(readlink -f $1)"
out_dir="$(basename $1 | sed 's/\.[^.]*$//')"
mkdir -p $out_dir
vd_dir="$(readlink -f $out_dir)"

set -x
self_dir=$(dirname $0)
pushd $self_dir
cmd1="ls $out_dir/tracks.npy"
cmd2="ls $out_dir/masked_droid_slam.npz"
cmd3="ls $out_dir/hps"
rm $out_dir ; ln -sf $vd_dir $out_dir  #soft link

set -x
# 1. Run detection, segmentation and multi-person tracking
$cmd1 2>/dev/null || python scripts/detect_track_video.py --video "$vd" --visualization && \ 

# 2. Run Masked DROID-SLAM, estimate a focal length
$cmd2 2>/dev/null || python scripts/slam_video.py --video "$vd" $img_focal && \

# 3. Run 4D human capture with VIMO.
$cmd3 2>/dev/null || python scripts/vimo_video.py --video "$vd" && \

# 4. Put everything together. Render the output video.
python scripts/tram_video.py --video "$vd" || (
  set +x
  echo
  echo "💡 Tip of known error"
  echo "❌ ValueError: bin_size too small, number of faces per bin must be less than 22;
Solution: set bin_size=-1 in /tram/scripts/tram_video.py
https://github.com/yufu-wang/tram/issues/5"
  echo
  echo "❌ ValueError: not enough values to unpack (expected 2, got 0)
Solution: https://github.com/yufu-wang/tram/issues/6"
)
