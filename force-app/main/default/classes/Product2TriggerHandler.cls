public class Product2TriggerHandler {      
    public static void AtualizaValorProduto(List<Product2> produtosLista){         
        list<Id> Idlist = new list<Id>();     
        list<Product2> ProdsToUpdate = new list<Product2>();         
        for(Product2 pr:produtosLista){         
            Idlist.add(pr.Id);     
        }     
        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = TRUE][0];     
        Id stPrId = pb.Id;         
        for(Product2 p:produtosLista){          
            for(Pricebookentry pbe:[select Product2Id,UnitPrice from Pricebookentry where Pricebook2Id = :stPrId and Product2Id IN :Idlist])
            {             
                If(pbe.Product2Id == p.Id){

                    ProdsToUpdate.add(p);             }         }            }           
                   If(ProdsToUpdate.size()>0&&trigger.isAfter){             
                       update ProdsToUpdate;     }     } }