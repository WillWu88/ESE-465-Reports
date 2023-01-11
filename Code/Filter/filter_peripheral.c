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
#include "sample.h"


int main()
{
    init_platform();

    volatile unsigned int* filter_ram = (unsigned short *)0x44a00000;
    volatile unsigned int* sample_buffer = (unsigned short *)0x44a00004;
    volatile unsigned int* marker = (unsigned short *)0x44a0000C;

    // write in filter coefficients
    for (int i = 0; i < NUM_TAPS; i++)
    {
    	*filter_ram = filter_coeff[i];
    }

    // zero out buffer
    for (int i = 0; i < NUM_TAPS; i++)
    {
    	*sample_buffer = 0;
    }
    // write in sample, wait for flag and extract result
    short filtered_result[SAMPLE_SIZE];

    int result;
    /*
    // one k sample
    for (int i = 0; i < SAMPLE_SIZE; i++)
    {
		*sample_buffer = one_k_sample[i];
		result = 0;
		while ((result & 0x80000000) == 0)
		{
			result = *sample_buffer;
		}
		one_k_result[i] = (short)(result & 0xFFFF);
    }

    // zero out work buffer once more
    // last write takes 24 out of 61 buffer slots,
    // needs two writes to reset read counter
    for (int i = 24; i < 61 ; i++)
    {
    	*sample_buffer = 0;
    }

    // zero out buffer
    for (int i = 0; i < NUM_TAPS; i++)
    {
        *sample_buffer = 0;
    }
	*/
    // process sample 2

    // start marker
    *marker = 0x00000001;
    for (int i = 0; i < SAMPLE_SIZE; i+=4)
    {
    	//unrolling for loop for times
    	*sample_buffer = one_k_sample[i];

    	// unrolling while loop
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	if ((result & 0x80000000) == 0)
    	{
			while ((result & 0x80000000) == 0)
			{
				result = *sample_buffer;
			}
    	}
    	filtered_result[i] = (short)(result & 0xFFFF);

    	*sample_buffer = one_k_sample[i+1];

    	// unrolling while loop
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	if ((result & 0x80000000) == 0)
    	{
    		while ((result & 0x80000000) == 0)
    		{
    			result = *sample_buffer;
    		}
    	}
    	filtered_result[i+1] = (short)(result & 0xFFFF);
    	*sample_buffer = one_k_sample[i+2];
    	// unrolling while loop
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	if ((result & 0x80000000) == 0)
    	{
    		while ((result & 0x80000000) == 0)
    	    {
    	    	result = *sample_buffer;
    	    }
    	}
    	filtered_result[i+2] = (short)(result & 0xFFFF);

    	*sample_buffer = one_k_sample[i+3];

    	// unrolling while loop
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	result = *sample_buffer;
    	if ((result & 0x80000000) == 0)
    	{
			while ((result & 0x80000000) == 0)
			{
				result = *sample_buffer;
			}
    	}
    	filtered_result[i+3] = (short)(result & 0xFFFF);
    }
    //stop marker
    *marker = 0;


    print("Done!");
    for (int i = 0; i < 1000; i++)
    {
    	xil_printf("%d, ", filtered_result[i]);
    }


    cleanup_platform();
    return 0;
}
