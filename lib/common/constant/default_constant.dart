

final ConstantValues constValue = ConstantValues._();
class ConstantValues{
  ConstantValues._();
   final String appBar="Zengraf";

  final String mobileNumber = "Mobile No";
  final String panNumber = "PAN Number";
  final String dateOfBirth = "Date Of Birth";
  final String name="Name";
  final String email="Email id";
  final String doorNo="Door No";
  final String area="Area";
  final String street="Street";
  final String city="City";
  final String state="State";
  final String country="Country";
  final String companyName="Company Name";
  final String industry="Industry";
  final String website="Website";
  final String source="Source";
  final String status="Status";
  final String rating="Rating";
  final String newLead="New Leads";
  final String addressInfo="Address Information (Optional)";
  final String companyInfo="Company Information (Optional)";
  final String socialInfo="Social Information";
  final String leadDetails="Lead Source Details (Optional)";
  final String leadGst="GST Information (Optional)";
  final String additionalInfo="Additional Information (Optional)";
  final String customFields="Custom Fields (Optional)";
  final String dashboard="Dashboard";
  final String lead="Lead";
  final String leads="Leads";
  final String goodLead="Good Leads";
  final String company="Company";
  final String client="Client";
  final String customer="Customers";
  final String hr="HR";
  final String products="Products";
  final String account = "Don't have an account?";
  final String addPhoto = "Add Photo";
  final String removePhoto = "Remove Photo";
  final String takePhoto = "Take Photo";
  final String galleryPhoto = "Choose photo from gallery";
  final String firstName = "First Name";
  final String lastName = "Last Name";
  final String middleName = "Middle Name";
  final String addStall = "Create Stall Information";
  final String viewStall = "View Stall Information";
  final String eventOr = "Event Organizers";
  final String eventRegister = "Event Register List";
  final String camera = "Camera";
  final String gallery = "Gallery";
  final String signUp = "Sign Up";
  final String img = "Select Image";


  final String stallName = "Stall Name";
  final String stallSize = "Stall Size";
  final convenienceField  = "Convenience Name";
  final String tag = "Tag";
  final String  mobile = " Mobile No";
  final String  fb = " FaceBook";
  final String  insta = " Instagram";
  final String  breakfast = " BreakFast";
  final String  lunch = " Lunch";
  final String  dinner = " Dinner";
  final String  count = " Count for ";
  final String  overall = " Overall";
  final String  live = " Live";
  final String  pending = " Pending";
  final String  food = " Food";
  final String  snacks = " Snacks";

  final int imgCOUNT = 2;
  final String save = "Save";
  final String cancel = "Cancel";
  final String send = "Send";
  final String noData = "No Data Found";
  final String noUser = "No User Found";
  final String noCase = "No Case Found";


}





// class SharedPref {
//
//   read(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return json.decode(prefs.getString(key)!);
//   }
//
//   save(String key, value) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString(key, json.encode(value));
//   }
//
//   remove(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.remove(key);
//   }
//
// }