class DogProfile {
  String breed;
  int age;
  String dogName;
  bool isDeleted;
  int creationTime;
  String imageUuid;

  DogProfile(this.breed, this.age, this.dogName, this.imageUuid,
      {this.creationTime = 0, this.isDeleted = false});

  Map<String, dynamic> toJson() => {
        'age': age,
        'breed': breed,
        'dogName': dogName,
        'isDeleted': isDeleted,
        'creationTime': creationTime,
        'imageUuid': imageUuid
      };

  DogProfile.fromJson(Map<String, dynamic> json)
      : age = json['age'],
        breed = json['breed'],
        dogName = json['dogName'] ?? '',
        isDeleted = json['isDeleted'] ?? false,
        imageUuid = json['imageUuid'] ?? '',
        creationTime = json['creationTime'] ?? 0;
}
