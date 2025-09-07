from django.db import models
from django.contrib.auth.models import User

class Department(models.Model):
    department = models.CharField(max_length=100)
    details = models.CharField(max_length=100)


class Course(models.Model):
    department = models.ForeignKey(Department, on_delete=models.CASCADE)
    course = models.CharField(max_length=100)

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # LoginId
    name = models.CharField(max_length=50)
    gender = models.CharField(max_length=50)
    place = models.CharField(max_length=50)
    post = models.CharField(max_length=50)
    pin = models.IntegerField()
    phone = models.BigIntegerField()
    email = models.CharField(max_length=100)
    image = models.ImageField(upload_to='user_images/')
    course=models.ForeignKey(Course, on_delete=models.CASCADE)
    status= models.CharField(max_length=50)


class Notification(models.Model):
    notification = models.CharField(max_length=100)
    details = models.CharField(max_length=100)
    date = models.DateField()

class Complaint(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    complaint = models.CharField(max_length=100)
    date = models.DateField()
    reply = models.CharField(max_length=100, blank=True, null=True)


class College(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)  # LoginId
    name = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    phone = models.BigIntegerField()
    proof = models.FileField(upload_to='college_proofs/')
    status = models.CharField(max_length=100)


class CourseRequest(models.Model):
    college = models.ForeignKey(College, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    date = models.DateField()
    status = models.CharField(max_length=100)

class Article(models.Model):
    title = models.CharField(max_length=100)
    subject = models.CharField(max_length=100)
    date = models.DateField()

class Parent(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE)  
    proof = models.FileField(upload_to='parent_proofs/')
    phone = models.BigIntegerField()

class Dataset(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    question = models.CharField(max_length=100)
    answer = models.CharField(max_length=200)

class ChatBot(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    dataset = models.ForeignKey(Dataset, on_delete=models.CASCADE)
    answer = models.CharField(max_length=200)
    date = models.DateField()
    score = models.IntegerField()

class LastAdmissionDetails(models.Model):
    college = models.ForeignKey(College, on_delete=models.CASCADE)
    course_request = models.ForeignKey(CourseRequest, on_delete=models.CASCADE)
    marks_starting = models.FloatField()
    marks_ending = models.FloatField()

class ChatbotResult(models.Model):
    chatbot = models.ForeignKey(ChatBot, on_delete=models.CASCADE)
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    result = models.CharField(max_length=100)

class Suggestion(models.Model):
    student = models.ForeignKey(UserProfile, on_delete=models.CASCADE)
    suggestion = models.CharField(max_length=100)
    details = models.CharField(max_length=100)
    college = models.ForeignKey(College, on_delete=models.CASCADE)
