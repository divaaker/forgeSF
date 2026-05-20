trigger Product2Trigger on Product2 (after update) {     
    if(Trigger.isAfter){         
        if(Trigger.isUpdate){             
            Product2TriggerHandler.AtualizaValorProduto(Trigger.new);         }     } }