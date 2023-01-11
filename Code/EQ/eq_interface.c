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
#include "coeff.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite.h"

#define UARTLITE_DEVICE_ID	XPAR_UARTLITE_0_DEVICE_ID
#define TEST_BUFFER_SIZE 16

int UartLitePolledExample(u16 DeviceId);

/************************** Variable Definitions *****************************/

XUartLite UartLite;		/* Instance of the UartLite Device */

/*
 * The following buffers are used in this example to send and receive data
 * with the UartLite.
 */
u8 SendBuffer[TEST_BUFFER_SIZE];	/* Buffer for Transmitting Data */
u8 RecvBuffer[TEST_BUFFER_SIZE];	/* Buffer for Receiving Data */


int main()
{
    volatile unsigned int* peripheral = (unsigned short* ) 0x44a00000;

    // filter set up
    for (int i = 0; i < NUM_TAPS; i++) {
    	for (int j = 0; j < NUM_FILTER; j++) {
    		*peripheral = filter_coeff[j][i];
    	}
    }

    for (int i = 0; i < NUM_TAPS*2; i++){
    	*peripheral = 0;

    }

    volatile unsigned int* bandMan[NUM_FILTER];
    for (int i = 0; i < NUM_FILTER; i++){
    	bandMan[i] = (i<<4) + 0x44a0000c;
    }

    xil_printf("Ready to ED");

    // receive attenuation
    int Status;

	// receive loop
    int received_str[NUM_FILTER];
	while (1){
		Status = UartLitePolledExample(UARTLITE_DEVICE_ID);

		// first 8 bands

		for (int i = 0; i < TEST_BUFFER_SIZE/2; i++){
			received_str[i] = RecvBuffer[i*2] * 0x100 + RecvBuffer[i*2+1];
		}

		//second read, for the last 5 bytes
		Status = UartLitePolledExample(UARTLITE_DEVICE_ID);

		// last 5 bands
		for (int i = 0; i < 5; i++){
			received_str[i+8] = RecvBuffer[i*2] * 0x100 + RecvBuffer[i*2+1];
		}

		for (int i = 0; i < NUM_FILTER; i++){
			*bandMan[i] = received_str[i];
		}
	}

	return XST_SUCCESS;
    //*bandMan[2] = 0x0000;

}

int UartLitePolledExample(u16 DeviceId)
{
	int Status;
	unsigned int ReceivedCount = 0;
	int Index;

	/*
	 * Initialize the UartLite driver so that it is ready to use.
	 */
	Status = XUartLite_Initialize(&UartLite, DeviceId);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Perform a self-test to ensure that the hardware was built correctly.
	 */
	Status = XUartLite_SelfTest(&UartLite);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Initialize the send buffer bytes with a pattern to send and the
	 * the receive buffer bytes to zero.
	 */
	for (Index = 0; Index < TEST_BUFFER_SIZE; Index++) {
		//SendBuffer[Index] = Index;
		RecvBuffer[Index] = 0;
	}

	/*
	 * Receive the number of bytes which is transferred.
	 * Data may be received in fifo with some delay hence we continuously
	 * check the receive fifo for valid data and update the receive buffer
	 * accordingly.
	 */
	while (1) {
		ReceivedCount += XUartLite_Recv(&UartLite,
					   RecvBuffer + ReceivedCount,
					   TEST_BUFFER_SIZE - ReceivedCount);
		if (ReceivedCount == TEST_BUFFER_SIZE) {
			break;
		}
	}
	return XST_SUCCESS;
}
