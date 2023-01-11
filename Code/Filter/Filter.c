/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "filter_coeff.h"

#define SUCCESS 0
#define FAILURE 1
#define ROUND_ADD 16384 // half of 2^14


typedef struct circ_buff{
    short * const buffer;
    int write;
    int read;
    const int buffer_max;
} circ_buff;

int buffUpdate(circ_buff *buff_ptr, short data)
{
    //overwrite write data first
    buff_ptr->buffer[buff_ptr->write] = data;

    //advance the write
    int next;
    if (buff_ptr->write+1 >= buff_ptr->buffer_max) {
        next = 0;
    } else {
        next = buff_ptr->write+1;
    }

    buff_ptr->write = next;

    if (next -1 < 0) {
    	buff_ptr->read = buff_ptr->buffer_max-1;
    } else {
    	buff_ptr->read = next - 1;
    }


    return SUCCESS;
}

short readBuffer(circ_buff *buff_ptr, int index)
{
    // check for out of bounds, deprecated it's filled with 0
    // if (buff_ptr->read == 0 && index > buff_ptr->write) {
        // return FAILURE;
    // }
    int buff_index;
    if (buff_ptr->read - index < 0) {
        buff_index = buff_ptr->buffer_max - index + buff_ptr->read;
    } else {
        buff_index = buff_ptr->read - index;
    }
    return buff_ptr->buffer[buff_index];

}

int conv(circ_buff *buff_ptr, const short *filter_coeff, int i)
{
	int filtered_sample = 0;
    for (int read_index = 0; read_index < buff_ptr->buffer_max; read_index++){
    	short sampled_data = readBuffer(buff_ptr, read_index);
        filtered_sample += (int)(sampled_data * filter_coeff[read_index]);
    }
    return filtered_sample;

}

void init_circbuff(short* buffer_array, int dim)
{
	for (int i = 0; i < dim; i++){
		*(buffer_array+i) = 0;
	}

}

short truncate_and_round(int filtered_int)
{
	//bit masking trick to extract bit 30 to bit 15
	int bit_mask = 0b01111111111111111000000000000000;
	return ((filtered_int + ROUND_ADD) & bit_mask) >> 15;
}

int main()
{
	init_platform();
    short process_buffer[NUM_TAPS];

    init_circbuff(process_buffer, NUM_TAPS);

    circ_buff filter_buffer = {.buffer = process_buffer, .write = 0, .read = -1, .buffer_max = NUM_TAPS};
    circ_buff *filter_ptr = &filter_buffer;
    volatile unsigned int* reg0 = (unsigned int *)0x44a00000;

    short filtered_sample[SAMPLE_SIZE];
    // flip bit for oscilloscope
    *reg0 = 0x00000001;
    for (int i = 0; i<SAMPLE_SIZE; i++){

    	buffUpdate(filter_ptr, eight_k_sin_wave[i]);
		filtered_sample[i] = truncate_and_round(conv(filter_ptr, filter_coeff, i));
    	xil_printf("%d, ", filtered_sample[i]);
    }
    *reg0 = 0x00000000;

    print("Done");
    cleanup_platform();
    return 0;
}
