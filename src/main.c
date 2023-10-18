#include "debug.h"
#include "ch32v20x.h"

void GPIO_init(void)
{
    GPIO_InitTypeDef GPIO_InitStructure = {0};

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
}

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

    GPIO_init();

    int i = 0;
    while (1) {
        Delay_Ms(500);
        GPIO_WriteBit(GPIOA, GPIO_Pin_0, (i == 0) ? (i = Bit_SET) : (i = Bit_RESET));
        printf("Tick:%ld\n", i);
    }
}
