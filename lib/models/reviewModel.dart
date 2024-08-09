// ignore_for_file: file_names, unnecessary_new, prefer_collection_literals, unnecessary_this

class Review {
  String? imageUrl;
  String? name;
  double? rating;
  String? date;
  String? comment;
  String? licenseNumber; // Added license number

  Review(
      {this.imageUrl,
      this.name,
      this.rating,
      this.date,
      this.comment,
      this.licenseNumber});

  Review.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    name = json['name'];
    rating = json['rating'];
    date = json['date'];
    comment = json['comment'];
    licenseNumber = json['licenseNumber']; // Added license number
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageUrl'] = this.imageUrl;
    data['name'] = this.name;
    data['rating'] = this.rating;
    data['date'] = this.date;
    data['comment'] = this.comment;
    data['licenseNumber'] = this.licenseNumber; // Added license number
    return data;
  }
}
