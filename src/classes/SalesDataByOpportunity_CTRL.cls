public with sharing class SalesDataByOpportunity_CTRL {
  private static Date currentDate = Date.today();
  private static Date startSelectedFY;
  private static Date endSelectedFY;
  private static final Integer startMonthFY = 6;

  private static final String oppStageName = 'Closed Won';

  private static Opportunity currentOpp;
  private static List<OpportunityLineItem> opportunityProducts = new List<OpportunityLineItem>();
  private static Map<String, PricebookEntry> priceBookEntryMap = new Map<String, PricebookEntry>();

  // Maps for sorting Opportunity Products By catalogies
  private static Map<String, DataByCatigoryType> dataByCatigoryTypeMap = new Map<String, DataByCatigoryType>();
  private static Map<String, DataByPublicationType> dataByPublicationTypeMap = new Map<String, DataByPublicationType>();
  private static Map<String, DataByPublicationName> dataByPublicationNameMap = new Map<String, DataByPublicationName>();
  private static Map<String, DataByProductName> dataByProductNameMap = new Map<String, DataByProductName>();
  private static Map<String, OportunityProduct> oportunityProductMap = new Map<String, OportunityProduct>();

  // Classes for creating data model for frontEnd

  public class TreeFactory {
    private String treeType;
    private Opportunity opp;
    private OpportunityLineItem oppProduct;
    private Boolean isCurrentYear;
    TreeFactory(String treeType, Opportunity opp, OpportunityLineItem oppProduct, Boolean isCurrentYear) {
      this.treeType = treeType;
      this.opp = opp;
      this.oppProduct = OppProduct;
      this.isCurrentYear = isCurrentYear;
    }
    public Tree createTree() {
      Tree tree;
      switch on this.treeType {
        when 'DataByCatigoryType' {
          tree = new DataByCatigoryType(this.oppProduct, this.opp, this.isCurrentYear);
        }
        when 'DataByPublicationType' {
          tree = new DataByPublicationType(this.oppProduct, this.opp, this.isCurrentYear);
        }
        when 'DataByPublicationName' {
          tree = new DataByPublicationName(this.oppProduct, this.opp, this.isCurrentYear);
        }
        when 'DataByProductName' {
          tree = new DataByProductName(this.oppProduct, this.opp, this.isCurrentYear);
        }
      }
      return (Tree)tree;
    }
  }

  public virtual class Tree {
    @AuraEnabled public String catalogName;
    @AuraEnabled public String keyField;
    @AuraEnabled public String isbutton;
    @AuraEnabled public Boolean isCurrentYear;
    @AuraEnabled public Object[] children_xxx;
    Tree(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear){
      this.isbutton = 'slds-hide';
      this.isCurrentYear = isCurrentYear;
    }
    public virtual void updateData (OpportunityLineItem oppProduct){}
  }

  public class DataByCatigoryType extends Tree {
    DataByCatigoryType(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear){
      super(oppProduct, currentOpp, isCurrentYear);
      this.keyField     = oppProduct.Publication__r.CC_PublicationTypeCategory__c;
      this.catalogName  = oppProduct.Publication__r.CC_PublicationTypeCategory__c;
      this.children_xxx = new List<DataByPublicationType>();
    }
  }

  public class DataByPublicationType extends Tree {
    DataByPublicationType(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear){
      super(oppProduct, currentOpp, isCurrentYear);
      this.keyField     = oppProduct.Publication__r.Publication_Type__c;
      this.catalogName  = oppProduct.Publication__r.Publication_Type__c;
      this.children_xxx = new List<DataByPublicationName>();
    }
  }

  public class DataByPublicationName extends Tree {
    @AuraEnabled public String publicationName;
    @AuraEnabled public Decimal quantity;
    @AuraEnabled public Decimal totalPrice;
    DataByPublicationName(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear){
      super(oppProduct, currentOpp, isCurrentYear);
      this.keyField         = oppProduct.Publication__r.Name;
      this.publicationName  = oppProduct.Publication__r.Name;
      this.quantity         = oppProduct.Quantity;
      this.totalPrice       = oppProduct.TotalPrice;
      this.catalogName      = oppProduct.Publication__r.Name;
      this.children_xxx     = new List<DataByProductName>();
    }
    public override void updateData (OpportunityLineItem oppProduct){
      this.quantity   += oppProduct.Quantity;
      this.totalPrice += oppProduct.TotalPrice;
    }
  }

  public class DataByProductName extends Tree {
    @AuraEnabled public String productName;
    @AuraEnabled public Decimal quantity;
    @AuraEnabled public Decimal totalPrice;
    @AuraEnabled public List<OpportunityLineItem> oppProducts;
    DataByProductName(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear){
      super(oppProduct, currentOpp, isCurrentYear);
      this.keyField     = oppProduct.Product2.Name;
      this.productName  = oppProduct.Product2.Name;
      this.quantity     = oppProduct.Quantity;
      this.totalPrice   = oppProduct.TotalPrice;
      this.children_xxx = new List<OportunityProduct>();
      this.oppProducts  = new List<OpportunityLineItem>();
      this.oppProducts.add(oppProduct);
      // Add button
      String currOppCategoryType = currentOpp.Publication_RE__r.CC_PublicationTypeCategory__c;
      if (isCurrentYear == false &&
          (currentOpp.StageName == 'Open' || currentOpp.StageName == 'Qualified') &&
          currOppCategoryType == oppProduct.Publication__r.CC_PublicationTypeCategory__c &&
          priceBookEntryMap.containsKey(oppProduct.Product2Id) &&
          currentOpp.Pricebook2Id == priceBookEntryMap.get(oppProduct.Product2Id).Pricebook2Id
      ) {
        this.isbutton = 'slds-show';
      }
    }
    public override void updateData (OpportunityLineItem oppProduct){
      this.quantity += oppProduct.Quantity;
      this.totalPrice += oppProduct.TotalPrice;
      this.oppProducts.add(oppProduct);
    }
  }

  public class OportunityProduct{
    @AuraEnabled public String keyField;
    @AuraEnabled public String publicationName;
    @AuraEnabled public String productName;
    @AuraEnabled public Decimal quantity;
    @AuraEnabled public Decimal totalPrice;
    @AuraEnabled public String signer;
    @AuraEnabled public Date closeDate;
    @AuraEnabled public String salesPerson;
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public String opportunityUrl;
    @AuraEnabled public String relatedOrg;
    @AuraEnabled public String chapter;
    @AuraEnabled public String parentAccount;
    @AuraEnabled public String location;
    @AuraEnabled public Decimal numberOfSubmissions;
    @AuraEnabled public String isbutton;
    @AuraEnabled public List<OpportunityLineItem> oppProducts;
    OportunityProduct(OpportunityLineItem oppProduct, Opportunity currentOpp, Boolean isCurrentYear) {
      this.keyField             = oppProduct.Id;
      this.publicationName      = oppProduct.Publication__r.Name;
      this.productName          = oppProduct.Product2.Name;
      this.quantity             = oppProduct.Quantity;
      this.totalPrice           = oppProduct.TotalPrice;
      this.signer               = oppProduct.Opportunity.Signer_text__c;
      this.closeDate            = oppProduct.Opportunity.CloseDate;
      this.salesPerson          = oppProduct.Opportunity.Owner.Name;
      this.opportunityId        = oppProduct.OpportunityId;
      this.opportunityUrl       = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppProduct.OpportunityId;
      this.relatedOrg           = oppProduct.Related_Organization__r.Name;
      this.chapter              = oppProduct.Chapter__r.Name;
      this.parentAccount        = oppProduct.Opportunity.Account.Name;
      this.location             = oppProduct.Location__r.Name;
      this.numberOfSubmissions  = oppProduct.Submissions__c;
      this.oppProducts          = new List<OpportunityLineItem>();
      this.oppProducts.add(oppProduct);
      // Add button
      String currOppCategoryType = currentOpp.Publication_RE__r.CC_PublicationTypeCategory__c;
      if (isCurrentYear == false &&
          (currentOpp.StageName == 'Open' || currentOpp.StageName == 'Qualified') &&
          currOppCategoryType == oppProduct.Publication__r.CC_PublicationTypeCategory__c &&
          priceBookEntryMap.containsKey(oppProduct.Product2Id) &&
          currentOpp.Pricebook2Id == priceBookEntryMap.get(oppProduct.Product2Id).Pricebook2Id
      ) {
        this.isbutton = 'slds-show';
      } else {
        this.isbutton = 'slds-hide';
      }
    }
  }

  public class SalesDataByOpportunityException extends Exception {}

  // Class for generating query conditions
  public class QueryCondition {
    @AuraEnabled public String value {get; set;}
    @AuraEnabled public String filterType {get; set;} 
    @AuraEnabled public String fieldName {get; set;}
    @AuraEnabled public String dataType {get; set;}

    public String generateContition(){
      String condition = ' AND ';
      switch on this.filterType {
        when 'equal' {
          if (this.dataType == 'string') {
            condition += this.fieldName + '=' + this.value;
          } else {
            condition += this.fieldName + '=' + String.escapeSingleQuotes(this.value);
          }
        }
        when 'like' {
          condition += this.fieldName + ' LIKE ' + '\'%' + String.escapeSingleQuotes(this.value) + '%\'';
        }
      }
      return condition;
    }
  }

  // Method retrieves Opportunity Products By filters
  // and sorts all Opportunity Products by catalog
  @AuraEnabled(cacheable=true)
  public static DataByCatigoryType[] getData(String oppId, Boolean isCurrentYear, List<QueryCondition> terms){
    selectRangeDate(isCurrentYear);
    getOpportunityProducts(oppId, isCurrentYear, terms);

    for(OpportunityLineItem oppProduct : opportunityProducts) {
      String catigoryType     = oppProduct.Publication__r.CC_PublicationTypeCategory__c;
      String publicationType  = oppProduct.Publication__r.Publication_Type__c;
      String publicationName  = oppProduct.Publication__r.Name;
      String productName      = oppProduct.Product2.Name;

      Tree dataByCatigoryType = sortDataByTree(
        oppProduct, 
        catigoryType,
        null,
        dataByCatigoryTypeMap,
        new TreeFactory('DataByCatigoryType', currentOpp, oppProduct, isCurrentYear)
      );
      
      Tree dataByPublicationType = sortDataByTree(
        oppProduct, 
        catigoryType + 'x' + publicationType,
        dataByCatigoryType,
        dataByPublicationTypeMap,
        new TreeFactory('DataByPublicationType', currentOpp, oppProduct, isCurrentYear)
      );
      
      Tree dataByPublicationName = sortDataByTree(
        oppProduct, 
        catigoryType + 'x' + publicationType + 'x' + publicationName,
        dataByPublicationType,
        dataByPublicationNameMap,
        new TreeFactory('DataByPublicationName', currentOpp, oppProduct, isCurrentYear)
      );

      Tree dataByProductName = sortDataByTree(
        oppProduct, 
        catigoryType + 'x' + publicationType + 'x' + publicationName + 'x' + productName,
        dataByPublicationName,
        dataByProductNameMap,
        new TreeFactory('DataByProductName', currentOpp, oppProduct, isCurrentYear)
      );

      dataByProductName.children_xxx.add(new OportunityProduct(oppProduct, currentOpp, isCurrentYear));
    }
    return dataByCatigoryTypeMap.values();
  }

  @AuraEnabled
  public static void createNewOppProduct(String oppId, String publicationId, List<OpportunityLineItem> oppProductsList){
    if(oppProductsList != null && 
      !oppProductsList.isEmpty() &&
      publicationId != null &&
      oppId != null
    ) {
      Decimal TotalPrice = 0;
      Decimal Quantity = 0;
      for (OpportunityLineItem oppProduct : oppProductsList) {
        TotalPrice  += oppProduct.TotalPrice != null ? oppProduct.TotalPrice : 0;
        Quantity    += oppProduct.Quantity != null ? oppProduct.Quantity : 0;
      }
      Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
      Map <String, Schema.SObjectField> fieldMap = 
        schemaMap.get('OpportunityLineItem').getDescribe().fields.getMap();
      List<String> fieldNames = new List<String>(fieldMap.keySet());
      String oppProductId = oppProductsList[0].Id;
      String query = 
        'SELECT ' + 
          String.join(fieldNames, ',') + 
        ' FROM OpportunityLineItem' + 
        ' WHERE Id =: oppProductId';
      OpportunityLineItem newOppProduct = Database.query(query);
      
      currentOpp = [
        SELECT Id, Pricebook2Id
        FROM Opportunity
        WHERE Id = :oppId
      ];
      List<PriceBookEntry> pbeList = [
        SELECT Id 
        FROM PriceBookEntry
        WHERE PriceBook2Id =: currentOpp.Pricebook2Id
          AND Product2Id =: newOppProduct.Product2Id
      ];
      newOppProduct.Id          = null;
      newOppProduct.TotalPrice  = TotalPrice;
      newOppProduct.Quantity    = Quantity;
      newOppProduct.Product2Id    = null;
      if (!pbeList.isEmpty()) {
        newOppProduct.PricebookEntryId = pbeList[0].Id;
      }
      if (Quantity == 1) {
				newOppProduct.UnitPrice               = null;
				newOppProduct.Related_Individual__c   = null;
				newOppProduct.Practice_Area__c        = null;
				newOppProduct.Location__c             = null;
				newOppProduct.Submissions__c          = null;
				newOppProduct.Description             = null;
				newOppProduct.No_of_Practice_Areas__c = null;
				newOppProduct.Qty_Books__c            = null;
				newOppProduct.OpportunityId           = oppId;
				newOppProduct.Publication__c          = publicationId;
			} else if (Quantity > 1){
				newOppProduct.UnitPrice               = null;
				newOppProduct.Related_Individual__c   = null;
				newOppProduct.Related_Organization__c = null;
				newOppProduct.Practice_Area__c        = null;
				newOppProduct.Location__c             = null;
				newOppProduct.Submissions__c          = null;
				newOppProduct.Description             = null;
				newOppProduct.Chapter__c              = null;
				newOppProduct.No_of_Practice_Areas__c = null;
				newOppProduct.Practice_Area_Text__c   = null;
				newOppProduct.Qty_Books__c            = null;
				newOppProduct.OpportunityId           = oppId;
				newOppProduct.Publication__c          = publicationId;
      }
      Database.insert(newOppProduct);
    } else {
      throw new SalesDataByOpportunityException(
        'Not enough data to add a product'
      );
    }
  }

  // Select Date Range depend on 'isCurrentYear' 
  private static void selectRangeDate(Boolean isCurrentYear){
    if(isCurrentYear == true) {
      if(currentDate.month() >= startMonthFY) {
        startSelectedFY = Date.newInstance(currentDate.year(), startMonthFY, 1);
        endSelectedFY   = startSelectedFY.addYears(1);
      } else {
        startSelectedFY = Date.newInstance(currentDate.addYears(-1).year(), startMonthFY, 1);
        endSelectedFY   = startSelectedFY.addYears(1);
      }
    } else {
      if(currentDate.month() >= startMonthFY) {
        startSelectedFY = Date.newInstance(currentDate.addYears(-1).year(), startMonthFY, 1);
        endSelectedFY   = startSelectedFY.addYears(1);
      } else {
        startSelectedFY = Date.newInstance(currentDate.addYears(-2).year(), startMonthFY, 1);
        endSelectedFY   = startSelectedFY.addYears(1);
      }
    }
  }

  // Method retrieves Opportunity Products By filters
  public static void getOpportunityProducts(String oppId, Boolean isCurrentYear, List<QueryCondition> terms) {
    currentOpp = [
      SELECT 
        Id, 
        Pricebook2.Name, 
        AccountId, 
        Account.Related_HO_Account__c, 
        StageName, 
        Pricebook2Id, 
        Publication_RE__r.Id, 
        Publication_RE__r.CC_PublicationTypeCategory__c
			FROM Opportunity
			WHERE Id = :oppId
    ];

    String HOAccount = currentOpp.Account.Related_HO_Account__c.substring(10, 25); // TODO: Ask about it
    String HOAccountId = '%' + HOAccount + '%';
    String query =
      'SELECT '+
      '  Id, '+
      '  Publication__c, '+
      '  Publication__r.CC_PublicationTypeCategory__c, '+
      '  Publication__r.Publication_Type__c, '+
      '  Publication__r.Name, '+
      '  OpportunityId, '+
      '  Product2Id, '+
      '  Product2.Name, '+
      '  Quantity, '+
      '  TotalPrice, '+
      '  Opportunity.Owner.Name, '+
      '  Opportunity.Signer_text__c, '+
      '  Opportunity.CloseDate, '+
      '  Related_Organization__r.Name, '+
      '  Chapter__r.Name, '+
      '  Opportunity.Account.Name, '+
      '  Location__r.Name, '+
      '  Submissions__c, '+
      '  Publication__r.Year_Issue_RE__c, '+
      '  Opportunity.Account.Related_HO_Account__c, '+
      '  Opportunity.Pricebook2Id '+
      'FROM OpportunityLineItem '+
      'WHERE Opportunity.Account.Related_HO_Account__c LIKE :HOAccountId '+
      '  AND Opportunity.StageName = :oppStageName '+
      '  AND Opportunity.Current_FY__c = :isCurrentYear '+
      '  AND Opportunity.CloseDate >= :startSelectedFY '+
      '  AND Opportunity.CloseDate < :endSelectedFY ';

      if (terms != null) {
        for (QueryCondition term : terms) {
          query += term.generateContition();
        }
      }
      query += ' ORDER BY Opportunity.CloseDate DESC ';
      opportunityProducts = Database.query(query);

      // Generate PriceBook2 Map Depend on Opportunity Products
      Set<String> productIdsSet = new Set<String>();
      for (OpportunityLineItem oppProduct : opportunityProducts) {
        productIdsSet.add(oppProduct.Product2Id);
      }
      System.debug('--->>>productIdsSet ' + productIdsSet);
      System.debug('--->>>currentOpp.Pricebook2Id ' + currentOpp.Pricebook2Id);
      List<PricebookEntry> pbeList = [
        SELECT Product2Id, Pricebook2Id
        FROM PricebookEntry 
        WHERE Product2Id IN :productIdsSet AND Pricebook2Id =: currentOpp.Pricebook2Id
      ];
        
      System.debug('--->>>pbeList ' + pbeList);
      for(PricebookEntry pbe : pbeList) {
        priceBookEntryMap.put(pbe.Product2Id, pbe);
      }
      System.debug('--->>>priceBookEntryMap ' + priceBookEntryMap);

  }
  // Method sorts Opportunity product By Tree type
  /**
   * @param oppProduct - {OpportunityLineItem}
   * @param key - {String} - Key for Map
   * @param parentTree - {Tree | null} - Parent Tree
   * @param treeMap - {Map<String, Tree>} - Map for sort
   * @param treeMap - {TreeFactory} - Tree Creator
   */
  private static Tree sortDataByTree(
    OpportunityLineItem oppProduct, 
    String key, 
    Tree parentTree, 
    Map<String, Tree> treeMap,
    TreeFactory treeFactory
  ) {
    Tree tree;
    if(treeMap.containsKey(key)) {
      tree = treeMap.get(key);
      tree.updateData(oppProduct);
    } else {
      tree = treeFactory.createTree();
      treeMap.put(key, tree);
      if (parentTree != null) {
        parentTree.children_xxx.add(tree);
      }
    }
    return (Tree)tree;
  }
}