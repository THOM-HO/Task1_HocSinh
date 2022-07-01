/**
* ClassName: CapNhatController
* ClassDetail: CapNhatController class
* @created: 2022/06/22 Hồ Thị Thơm
* @modified:
*/
public with sharing class CapNhatController {
    
  public Condition cond {get; set;}
  private String page=''; //Chứa tên page đã duy chuyển qua
     
    public CapNhatController() {
        String param = ApexPages.currentPage().getParameters().get('id'); //id của hs cần cập nhật
        page = ApexPages.currentPage().getParameters().get('page'); 
        cond= new Condition(); 
        initData( param);
    }
    
    //Khởi tạo
    public void initData(String param){
        HocSinh__c hs= new HocSinh__c();
         			hs=[SELECT  MaHocSinh__c,HoHocSinh__c,TenHocSinh__c,NgaySinh__c,GioiTinh__c, Diem1__c, Diem2__c,Diem3__c
						FROM HocSinh__C
						WHERE Id = :param ];
     cond.objHsCondition.TenHocSinh__c = hs.TenHocSinh__c;
     cond.objHsCondition.HoHocSinh__c =hs.HoHocSinh__c;
     cond.objHsCondition.NgaySinh__c = hs.NgaySinh__c;
     cond.objHsCondition.GioiTinh__c = hs.GioiTinh__c;
     cond.objHsCondition.Diem1__c = hs.Diem1__c;
     cond.objHsCondition.Diem2__c = hs.Diem2__c;
     cond.objHsCondition.Diem3__c = hs.Diem3__c;
     cond.objHsCondition.Id = hs.Id;
    }
    
    public PageReference back(){
        PageReference pg = new PageReference('/apex/'+page);
        pg.getParameters().put('id',cond.objHsCondition.Id);
		return pg;
    }
    
    // Update HS 
    public PageReference updateHS(){
        HocSinh__c hs= new HocSinh__c();
        hs.Id= cond.objHsCondition.Id;
        hs.TenHocSinh__c= cond.objHsCondition.TenHocSinh__c;
        hs.HoHocSinh__c =  cond.objHsCondition.HoHocSinh__c;
        hs.GioiTinh__c= cond.objHsCondition.GioiTinh__c;
        hs.NgaySinh__c= cond.objHsCondition.NgaySinh__c;
        hs.Diem1__c=cond.objHsCondition.Diem1__c;
        hs.Diem2__c=cond.objHsCondition.Diem2__c;
        hs.Diem3__c=cond.objHsCondition.Diem3__c;
        
        update hs;
        PageReference pg = new PageReference('/apex/'+page);
        pg.getParameters().put('id',cond.objHsCondition.Id);
		return pg;
    }
    
    class Condition {
		public HocSinh__c objHsCondition {get; set;}
		public String lopId {get; set;}
        
		public Condition () {
			objHsCondition = new HocSinh__c();
		}    
	}
}