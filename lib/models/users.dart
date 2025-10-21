class User {
  int id, online_id, role_id;
  String role_name, first_name, last_name, contact,email,password_hash,slug;
  bool is_active;

  User(
      this.id,
      this.online_id,
      this.role_id,
      this.role_name,
      this.first_name,
      this.last_name,
      this.contact,
      this.email,
      this.password_hash,
      this.is_active,
      this.slug);

  User.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        online_id= json['id'],
        role_id= json['role_id'],
        role_name= "user",
        first_name= json['first_name'],
        last_name= json['last_name'],
        contact= json['contact'],
        email= json['email'],
        password_hash= "123456789",
        is_active= json['is_active']==1?true:false,
        slug= json['slug'];
}
