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


#define ADC_CYCLE_MAX 16
#define DAC_CYCLE_MAX 24
#define SAMP_PER_CLOCK 600
#define CHANNEL_0 0x800000
#define CHANNEL_1 0xC00000
#define SAMPLE_SIZE 1000

#define CHANNEL_0_DAC 0x00
#define CHANNEL_1_DAC 0x01
#define FAST_MODE 0x5
#define TRANSMIT 0x3


void twosComplement(short* result)
{
	short lower_15 = *result & 0b0111111111111111;
	short upper_bit = !((*result & 0b1000000000000000) >> 15) << 15;

	*result = lower_15 + upper_bit;
}

void readSDO(volatile unsigned int* sdo_ptr, short* storage)
{
	int result = 0;
	while ((result & 0x80000000) == 0)
	{
		result = *sdo_ptr;
	}
	*storage = (short)(result & 0xFFFF);
}

/*
unsigned short flip16(short* sample_data)
{
	// flip the bit order of 16 data
	unsigned short val = *sample_data;
	val = (val & 0xFF00) >> 8 | (val & 0x00FF) << 8;
	val = (val & 0xF0F0) >> 4 | (val & 0x0F0F) << 4;
	val = (val & 0xCCCC) >> 2 | (val & 0x3333) << 2;
	val = (val & 0xAAAA) >> 1 | (val & 0x5555) << 1;
	return val;

}
short flip4(short bit)
{
	short return_val = bit;
	return_val = (bit & 0xC) >> 2 | (bit & 0x3) << 2;
	return (int)((return_val & 0xA) >> 1 | (return_val & 0x5) << 1);

}

int flipSdi(short* sample_data, short control_bits, short addr_bits)
{
	flip16(sample_data);
	int final_result = (((unsigned int)(*sample_data)) << 8) + ((int)flip4(addr_bits) << 4) + (int)flip4(control_bits);

	return final_result & 0xFFFFFF;
}
*/


int main()
{
    init_platform();

    // adc registers
    volatile unsigned int* adc_sdi_reg = (unsigned int*) 0x44a10000;
    volatile unsigned int* adc_sdo_reg = (unsigned int*) 0x44a10004;
    volatile unsigned int* adc_cycle_max_reg = (unsigned int*) 0x44a10008;
    volatile unsigned int* adc_spc_reg = (unsigned int*) 0x44a1000c;

    // dac registers
    volatile unsigned int* dac_sdi_reg = (unsigned int*) 0x44a00000;
    volatile unsigned int* dac_sdo_reg = (unsigned int*) 0x44a00004;
    volatile unsigned int* dac_spc_reg = (unsigned int*) 0x44a0000c;
    volatile unsigned int* dac_cycle_max_reg = (unsigned int*) 0x44a00008;


/*
    // adc spi config
    *adc_cycle_max_reg = ADC_CYCLE_MAX;
    *adc_spc_reg = SAMP_PER_CLOCK;

    // discard first bit
    int result = 0;
    while ((result & 0x80000000) == 0)
   	{
   		result = *adc_sdo_reg;
  	}

    // read sample out from two channels
    unsigned short channel_zero_out[SAMPLE_SIZE];


    for (int i = 0; i < SAMPLE_SIZE*2; i+=2)
    {
    	// read from channel 0
    	*adc_sdi_reg = CHANNEL_0;
    	result = 0;
    	while ((result & 0x80000000) == 0)
    	{
    		result = *adc_sdo_reg;
    	}
    	channel_zero_out[i] = (unsigned short)(result & 0xFFFF);

    	// empty read for channel 1
    	*adc_sdi_reg = CHANNEL_1;
    	result = 0;
    	while ((result & 0x80000000) == 0)
    	{
    		result = *adc_sdo_reg;
    	}
    	channel_zero_out[i+1] = (unsigned short)(result & 0xFFFF);
    	//readSDO(*adc_sdo_reg, channel_one_out + i);
    }
    for (int i = 0; i < SAMPLE_SIZE*2; i+=2)
    {
    	xil_printf("%d\n", channel_zero_out[i]);
    }
    for (int i = 0; i < SAMPLE_SIZE*2; i+=2)
    {
        xil_printf("%d\n", channel_zero_out[i+1]);
    }

/*
    // dac spi config
    *dac_cycle_max_reg = DAC_CYCLE_MAX;
    *dac_spc_reg = SAMP_PER_CLOCK;

    // fast mode switch
	unsigned int data = (unsigned int) *(one_k_sample);
	*dac_sdi_reg = (FAST_MODE << 20) + (CHANNEL_0_DAC << 16) + data;
	int result = 0;
	while ((result & 0x80000000) == 0)
	{
		result = *dac_sdo_reg;
	}
	*dac_sdi_reg = (TRANSMIT << 20) + (CHANNEL_0_DAC << 16) + data;
	result = 0;
		while ((result & 0x80000000) == 0)
		{
			result = *dac_sdo_reg;
		}
	*dac_sdi_reg = (FAST_MODE << 20) + (CHANNEL_1_DAC << 16) + data;
	result = 0;
		while ((result & 0x80000000) == 0)
		{
			result = *dac_sdo_reg;
		}
	*dac_sdi_reg = (TRANSMIT << 20) + (CHANNEL_1_DAC << 16) + data;
	result = 0;
	while ((result & 0x80000000) == 0)
	{
		result = *dac_sdo_reg;
	}
	int i = 0;

    while (1){
		data = (unsigned int) *(one_k_sample + i);
		*dac_sdi_reg = 0x300000 + data; // channel 0
		result = 0;
		while ((result & 0x80000000) == 0)
		{
			result = *dac_sdo_reg;
		}
		data = (unsigned int) *(nine_k_sample + i);
		*dac_sdi_reg = 0x310000 + data; //channel 1
		result = 0;
		while ((result & 0x80000000) == 0)
		{
			result = *dac_sdo_reg;
		}

		if (i < 1000)
		{
			i++;
		} else {
			i = 0;
		}
    }


    //loop back mode
*/
    // adc spi config
    *adc_cycle_max_reg = ADC_CYCLE_MAX;
    *adc_spc_reg = SAMP_PER_CLOCK;
    // dac spi config
    *dac_cycle_max_reg = DAC_CYCLE_MAX;
    *dac_spc_reg = SAMP_PER_CLOCK;
    // discard first bit
    int result = 0;
    while ((result & 0x80000000) == 0)
    {
    	result = *adc_sdo_reg;
    }
    unsigned short data_out;

    // fast mode switch

    *dac_sdi_reg = (FAST_MODE << 20) + (CHANNEL_0_DAC << 16);

    while ((result & 0x80000000) == 0)
    {
    	result = *dac_sdo_reg;
    }
    *dac_sdi_reg = (TRANSMIT << 20) + (CHANNEL_0_DAC << 16);
    result = 0;
    while ((result & 0x80000000) == 0)
    {
    	result = *dac_sdo_reg;
    }
    *dac_sdi_reg = (FAST_MODE << 20) + (CHANNEL_1_DAC << 16);
    result = 0;
    while ((result & 0x80000000) == 0)
    {
    	result = *dac_sdo_reg;
    }
    *dac_sdi_reg = (TRANSMIT << 20) + (CHANNEL_1_DAC << 16);
    result = 0;
    while ((result & 0x80000000) == 0)
    {
    	result = *dac_sdo_reg;
    }

    unsigned int* data;
    short channel_switch = 0;
    while(1)
    {

    	if (!channel_switch){
			// read from channel 0
			*adc_sdi_reg = CHANNEL_0;
			result = 0;
			while ((result & 0x80000000) == 0)
			{
				result = *adc_sdo_reg;
			}
			data_out = (unsigned short)(result & 0xFFFF);

			*dac_sdi_reg = 0x300000 + (unsigned int)data_out; // channel 0
			result = 0;
			while ((result & 0x80000000) == 0)
			{
				result = *dac_sdo_reg;
			}
			channel_switch = 1;
    	}
    	else
    	{
			// read for channel 1
			*adc_sdi_reg = CHANNEL_1;
			result = 0;
			while ((result & 0x80000000) == 0)
			{
				result = *adc_sdo_reg;
			}
			data_out = (unsigned short)(result & 0xFFFF);

			*dac_sdi_reg = 0x310000 + (unsigned int)data_out; //channel 1
			result = 0;

			while ((result & 0x80000000) == 0)
			{
				result = *dac_sdo_reg;
			}
			channel_switch = 0;
    	}
    }


    cleanup_platform();
    return 0;
}
