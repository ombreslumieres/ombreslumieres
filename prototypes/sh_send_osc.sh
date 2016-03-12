#!/bin/bash
PORT=31337

osc-send -p ${PORT} /spray/at ,ii 10 10
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 20 20
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 30 30
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 40 40
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 50 50
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 60 60
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 70 80
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/at ,ii 90 90
python -c "import time; time.sleep(0.1)"
osc-send -p ${PORT} /spray/end 
