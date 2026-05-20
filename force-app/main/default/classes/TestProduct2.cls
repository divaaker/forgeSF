@isTest public class TestProduct2 {      
    @isTest       
    static void AtualizaValorProduto(){         
        Product2 prod = new Product2(Name = 'Laptop X200',                                       
                                     Family = 'Hardware' 
                                     );         
        insert prod;                 
        Id pricebookId = Test.getStandardPricebookId();                  
        //criar uma lista de produtos, chamar o método da classe Product2TriggerHandler AtualizaValorProduto passando a lista dos produtos criados         
		PricebookEntry standardPrice = new PricebookEntry(             
            Pricebook2Id = pricebookId, Product2Id = prod.Id,             
            UnitPrice = 10000, IsActive = true);         
        insert standardPrice;                   
        PricebookEntry pb = [SELECT Pricebook2Id, Product2Id, UnitPrice, isActive FROM PricebookEntry WHERE Product2Id =: prod.Id];        
        pb.UnitPrice = 199;                  test.startTest();         update prod;                           test.stopTest();                
        Product2 prodTest = [SELECT Name, Family, Id FROM Product2 WHERE Id =: prod.Id];            } }