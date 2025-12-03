@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tipo de Cambio'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_I_TIPOCAMBIO 
with parameters
    P_FiscalYear      : gjahr,       // Año Fiscal
    P_Period          : periv,       // Periodo Contable
    P_ExchRateType    : kurst,       // Tipo de Cotización
    P_FromCurrency    : waers,       // Moneda Origen
    P_ToCurrency      : waers        // Moneda Destino

as select from I_ExchangeRateRawData
 inner join I_CompanyCode
    on '5710' = I_CompanyCode.CompanyCode
{
    key I_ExchangeRateRawData.ExchangeRateType,
    key I_ExchangeRateRawData.SourceCurrency,
    key I_ExchangeRateRawData.TargetCurrency,
    key I_ExchangeRateRawData.ValidityStartDate,

    @Semantics.amount.currencyCode: 'SourceCurrency'
    @UI.lineItem: [{ position: 10 }]
    @EndUserText.label: 'Exchange Rate (2 Decimals)'
    cast( round( I_ExchangeRateRawData.ExchangeRate, 2 ) as abap.decfloat34 ) as ExchangeRate_2Decimals,

    @Semantics.amount.currencyCode: 'SourceCurrency'
    @UI.lineItem: [{ position: 20 }]
    @EndUserText.label: 'Exchange Rate (3 Decimals)'
    case 
        when cast( round(I_ExchangeRateRawData.ExchangeRate * 1000, 0) as abap.int4 ) / 10 = 0 
        then cast(round(I_ExchangeRateRawData.ExchangeRate, 3) as abap.decfloat34) 
        else cast(round(I_ExchangeRateRawData.ExchangeRate, 3) as abap.decfloat34) 
    end as ExchangeRate_3Decimals,
    
    
    //@UI.lineItem: [{ position: 30 }]
    @EndUserText.label: 'Exchange Rate (Full Precision)'
    // Eliminamos la referencia a moneda
    cast(I_ExchangeRateRawData.ExchangeRate as abap.decfloat34) as ExchangeRate_Full,
    
    @UI.lineItem: [{ position: 40 }]
    @EndUserText.label: 'Exchange Rate (3 Decimals as Text)'
    cast( round( I_ExchangeRateRawData.ExchangeRate, 3 ) as abap.char(50) ) as ExchangeRate_3Decimals_Text,

    I_ExchangeRateRawData.NumberOfSourceCurrencyUnits,
    I_ExchangeRateRawData.NumberOfTargetCurrencyUnits,
    substring(I_ExchangeRateRawData.ValidityStartDate, 1, 4) as year1,
    substring(I_ExchangeRateRawData.ValidityStartDate, 5, 2) as mes1,
    substring(I_ExchangeRateRawData.ValidityStartDate, 7, 2) as day1,

    I_CompanyCode.VATRegistration,

    /* Associations */
    I_ExchangeRateRawData._ExchangeRateType,
    I_ExchangeRateRawData._SourceCurrency,
    I_ExchangeRateRawData._TargetCurrency
}
where
    substring(I_ExchangeRateRawData.ValidityStartDate, 1, 4) = $parameters.P_FiscalYear
    and substring(I_ExchangeRateRawData.ValidityStartDate, 5, 2) = $parameters.P_Period
    and I_ExchangeRateRawData.ExchangeRateType = $parameters.P_ExchRateType
    and I_ExchangeRateRawData.SourceCurrency = $parameters.P_FromCurrency
    and I_ExchangeRateRawData.TargetCurrency = $parameters.P_ToCurrency
