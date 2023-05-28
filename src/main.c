#include "debug.h"
#include "ch32v20x.h"

int main(void)
{
    RCC_ClocksTypeDef RCC_ClocksStatus = {0};

    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
    Delay_Init();
    Delay_Ms(100);

    USART_Printf_Init(115200);
    printf("SystemClk:%ld\n", SystemCoreClock);

    SystemCoreClockUpdate();
    printf("SystemClk:%ld\n", SystemCoreClock);

    RCC_GetClocksFreq(&RCC_ClocksStatus);
    printf("SYSCLK_Frequency-%ld\n", RCC_ClocksStatus.SYSCLK_Frequency);

    while (1) {

    }
}
