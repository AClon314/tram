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
rm -r $out_dir ; ln -sf $vd_dir $out_dir  #soft link

set -x
# 1. Run Masked Droid SLAM (also detect+track humans in this step)
python scripts/estimate_camera.py --video "$vd" --static_camera && \

# 2. Run 4D human capture with VIMO.
$cmd3 2>/dev/null || python scripts/estimate_humans.py --video "$vd" && \

# 3. Put everything together. Render the output video.
python scripts/visualize_tram.py.py --video "$vd" || (
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
