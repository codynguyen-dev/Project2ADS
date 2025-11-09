cd ~/ADHD.Projects

# Create the compile script
cat > compile.sh << 'EOF'
#!/bin/bash
set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Mandelbrot Project Compilation ===${NC}"

VCOM="vcom -2008"
VLIB="vlib"

if [ "$1" == "clean" ]; then
    echo -e "${YELLOW}Cleaning...${NC}"
    rm -rf work ads vga *.wlf transcript vsim.wlf mandelbrot_output.ppm
    echo -e "${GREEN}Clean complete!${NC}"
    exit 0
fi

echo -e "${YELLOW}Creating libraries...${NC}"
$VLIB ads 2>/dev/null || true
$VLIB vga 2>/dev/null || true
$VLIB work 2>/dev/null || true

echo -e "${YELLOW}Compiling ads library...${NC}"
$VCOM -work ads ads_fixed.vhd
$VCOM -work ads ads_complex.vhd

echo -e "${YELLOW}Compiling vga library...${NC}"
$VCOM -work vga vga_data.vhd
$VCOM -work vga vga_fsm.vhd

echo -e "${YELLOW}Compiling work library...${NC}"
$VCOM -work work color_data.vhd
$VCOM -work work coordinate_mapper.vhd
$VCOM -work work mandelbrot_stage.vhd
$VCOM -work work mandelbrot_pipeline.vhd
$VCOM -work work color_mapper.vhd
$VCOM -work work ADSProj2CIAOTopLevel.vhd

echo -e "${GREEN}Compilation successful!${NC}"

if [ "$1" == "sim" ]; then
    echo -e "${YELLOW}Compiling testbench...${NC}"
    $VCOM -work work mandelbrot_pbm_tb.vhd
    echo -e "${YELLOW}Running simulation (this will take a while)...${NC}"
    vsim -c -do "run -all; quit" mandelbrot_pbm_tb
    if [ -f "mandelbrot_output.ppm" ]; then
        echo -e "${GREEN}Image generated: mandelbrot_output.ppm${NC}"
    fi
fi
EOF

chmod +x compile.sh
