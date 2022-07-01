/**
* ClassName: TimKiemController
* ClassDetail: 
* @created: 2022/06/23 Ho Thi Thom
* @modified:
*/
public with sharing class TimKiemController {
 
 public List<SelectOption> options {get; set;} // select public List<HocSinh>    
 public List<HocSinh> lvHocSinh{get;set;} // Danh sách học sinh hiển thị ra view
 public Condition cond {get; set;} // Đối tượng Cond
 public Integer count {get; set;}  // Số lượng học sinh truy vấn được
 public Integer currentPage {get; set;} // Trang hiện tại được chọn
 private Integer LIMIT_ROW = 5;// Số dòng giới hạn hiển thị  
 public Integer totalPage {get; set;} // Tổng số trang phân trang
 public Integer numberPageShow = 3; // Số trang hiển thị
 public List<Integer> listPage {set; get;}   // List trang được hiển thị EX: 1,2,3 OR 2,3,4
 private String SELECT_ALL = 'ALL';
 public Boolean isNotification {get; set;} // check hiện thông báo chưa nhập điều kiện tìm kiếm
    /*
	Khởi tạo options chứa ds lớp
	Khởi tạo lvHocSinh chứa ds học sinh sẽ hiển thị ra view
	Khởi tạo listPage số phân trang
	Khởi tạo data ban đầu init
	Khởi tạo Cond
	*/
    public TimKiemController() {
        options = new List<SelectOption>();
        lvHocSinh = new List<HocSinh>();
        listPage = new List<Integer>(); 
        cond = new Condition();
        initData();
        isNotification=false;
    }
     
    public void initData(){
        try {
            // Lấy dữ liệu danh sách lớp hiển thị ra selection
            options.add(new SelectOption(SELECT_ALL, 'Tất cả') )  ;
			for(Lop__c lop : [SELECT Id, TenLop__c FROM Lop__c ORDER BY TenLop__c]) {
               options.add(new SelectOption(lop.Id, lop.TenLop__c) )  ;           
            }
             if (options.isEmpty()) {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.MSG_ERROR_NORESULT));
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Data not found'));
			}
            //Trang hiện tại
            currentPage = 1;
            totalPage = 1;
            //tổng số trang
            Count();
            queryHocSinh();
		} catch (Exception ex) {
            System.debug('====================>abc');
		}
        
    }
    
    // Tạo điều kiện query
     public String condQuery(String queryString){
        String TenHS= cond.objHsCondition.TenHocSinh__c;  
        String LopId= cond.lopId;
        Date Ngay1= cond.objHsCondition.NgaySinh__c;
        Date Ngay2= cond.objHsCondition1.NgaySinh__c;
         
		try {
			if(TenHS != null && TenHS.trim() != '') {
				queryString += ' AND TenHocSinh__c like \'%' + String.escapeSingleQuotes(TenHS)+'%\'';
           }
           
			if(LopId != null && LopId != SELECT_ALL) {
				queryString += ' AND Lop__c =\''+LopId+'\'';  
		   }
    
            if( Ngay1 != null && Ngay2 != null){
               //Cắt lấy ngày
       		   String dt1= String.valueOf(Ngay1).substring(0,10);
       		   String dt2= String.valueOf(Ngay2).substring(0,10);
               queryString += 'AND NgaySinh__c > '+dt1+' AND NgaySinh__c < '+ dt2;
            }
           
           // thay đổi chuỗi
		    queryString = queryString.replaceFirst('AND', 'WHERE');
            
			return queryString;            
		} catch (Exception ex) {
			return null;
		}
    } 
    
    // đếm số lượng đối tượng tìm được và setup phân trang
     public void Count(){
        String queryCount='SELECT COUNT() FROM HocSinh__c';
        queryCount= condQuery(queryCount);
        count = Database.countQuery(queryCount);
        totalPage = (Integer) Math.ceil((Decimal) count / LIMIT_ROW);
     }
    
    // Truy vấn học sinh
    public void queryHocSinh(){
        lvHocSinh.clear();
        String queryHS='SELECT Id, MaHocSinh__c, HoHocSinh__c, TenHocSinh__c, NgaySinh__c, GioiTinh__c, Diem1__c, Diem2__c,Diem3__c, DiemTB__c,TinhTrang__c FROM  HocSinh__c';
        // rap điều kiện
        queryHS= condQuery(queryHS);
        if(cond.objHsCondition.GioiTinh__c){
         	queryHS += ' ORDER BY TenHocSinh__c  ';
        }else{
           queryHS += ' ORDER BY TenHocSinh__c  DESC ';
        }
        queryHS +=' LIMIT '+LIMIT_ROW;
        Integer offsetNum= (LIMIT_ROW * (currentPage - 1));
        queryHS += 'OFFSET '+offsetNum;
        List<HocSinh__c> hs=  Database.query(queryHS);
        if(!hs.isEmpty()){
            for(HocSinh__c item : hs){
                lvHocSinh.add(new HocSinh(false,item));
            }
            getPages();
        }
     }
    
    //phân trang
    public void getPages(){
        listPage.clear();
        Integer distance = (Integer) Math.ceil((Decimal) numberPageShow / 2);
        Integer firstPage = currentPage - distance + 1;
        
        if(firstPage > totalPage - distance){
            firstPage = totalPage - numberPageShow + 1;
        }
        
        if(firstPage < 1) {
			firstPage = 1;
        }
        
        Integer index = 0;
        
        if(totalPage < numberPageShow) index = numberPageShow - totalPage;
        for(Integer i = index; i < numberPageShow; i++){
            listPage.add(firstPage++);
        }
    }
    
    // thực hiện search
    public void searchStudent(){
        lvHocSinh.clear();
        count=0;
        Date Ngay1= cond.objHsCondition.NgaySinh__c;
        Date Ngay2= cond.objHsCondition1.NgaySinh__c;
            if(cond.objHsCondition.TenHocSinh__c != null ||(cond.LopId != null && cond.LopId != SELECT_ALL) ||(Ngay1 != null && Ngay2!= null)){
                  isNotification=false;
                  currentPage = 1;
          		  Count();
           		  queryHocSinh(); 
            }else{
               isNotification= true; 
            }  
    }
   
    // Duy chuyển sang trang thêm mới
    public PageReference addStudent(){
        PageReference pg = new PageReference('/apex/VF_ThemMoi');
		return pg;
    }
    
    //Detail
    public PageReference Detail(){
        String param = ApexPages.currentPage().getParameters().get('index');
        String idHS = lvHocSinh.get(Integer.valueOf(param)).objHocSinh.Id;
        PageReference pg = new PageReference('/apex/VF_ChiTiet');
        pg.getParameters().put('id',idHS);
		return pg;
    }
    
    //Xóa 1 học sinh
    public void DeleteHS(){
        String param = ApexPages.currentPage().getParameters().get('index');
        String idHS = lvHocSinh.get(Integer.valueOf(param)).objHocSinh.Id;
        HocSinh__c hs= new HocSinh__c(Id=idHS);
        delete hs;
        currentPage = 1;
        Count();
        queryHocSinh(); 
    }
    //CheckAll
    public void DeleteCheck(){
        List<HocSinh__c> hocsinhs= new List<HocSinh__c>();
        for(HocSinh item : lvHocSinh){
            if(item.check){
                String id= item.objHocSinh.Id;
                HocSinh__c hs= new HocSinh__c(Id=id);
       			hocsinhs.add(hs); 
            }
        }
        delete(hocsinhs);
        currentPage = 1;
        Count();
        queryHocSinh(); 
        cond.objHsCondition1.GioiTinh__c=false;
    }
     //CheckAll
    public void IsCheckAll(){
        if(cond.objHsCondition1.GioiTinh__c){
            for(HocSinh item : lvHocSinh){
            item.check=true;
          }
        }else{
           for(HocSinh item : lvHocSinh){
            item.check=false; 
           }
        }
    }
    
    // duy chuyển sang trang chỉnh sửa học sinh
    public PageReference UpdateHS(){
        String param = ApexPages.currentPage().getParameters().get('index');
        String idHS = lvHocSinh.get(Integer.valueOf(param)).objHocSinh.Id;
        PageReference pg = new PageReference('/apex/VF_CapNhat');
        pg.getParameters().put('id',idHS);
        pg.getParameters().put('page','VF_TimKiem');
		return pg;
    }
    
    //pagination
    public void nextPage(){
        if(currentPage + 1 > totalPage )return;
          currentPage +=1;
         queryHocSinh();
    }
  	//prevPage
	public void prevPage(){
        if(currentPage == 1 )return;
        currentPage -=1;
           queryHocSinh();  
    }
    
    public void firstPage(){
        currentPage =1;
        queryHocSinh();
    }
    
    public void lastPage(){
        currentPage = totalPage;
        queryHocSinh();
    }
    
    // tùy chọn phân trang
    public void setPage(){
        String param = ApexPages.currentPage().getParameters().get('index');
        currentPage = Integer.valueOf(param);
        queryHocSinh();
    }
    
    class Condition {
		public HocSinh__c objHsCondition {get; set;}
        public HocSinh__c objHsCondition1 {get; set;}
		public String lopId {get; set;}
		public Condition () {
			objHsCondition = new HocSinh__c();
            objHsCondition1 = new HocSinh__c();
		}      
	}
    class HocSinh{
      public Boolean check {get; set;}
      public HocSinh__c objHocSinh {get; set;}
        public HocSinh() {
        }
        public HocSinh(Boolean check, HocSinh__c hs){
            this.check= check;
            this.objHocSinh= hs;
        }
    }
}