from django.db.models import Sum
import json
import random
from django.core.files.storage import FileSystemStorage
from datetime import datetime, timezone
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render
from django.db.models import Q
from django.contrib.auth.models import User ,Group 
from django.contrib.auth import authenticate, login, logout
from django.utils import timezone
from guidanceapp.Geminiapi import gpt_course_classifier, gpt_score_answer
from guidanceapp.models import *
from django.contrib.auth.hashers import check_password, make_password
from django.contrib.auth.decorators import login_required

# Create your views here.

def home(request):
    return render(request, 'index.html')

def adminhome(request):
    return render(request, 'Admin/home.html')

def collegehome(request):
    return render(request, 'College/home.html')


from django.contrib.auth import authenticate, login
from django.http import HttpResponse
from django.shortcuts import render
from .models import College, UserProfile, Parent  # Make sure these models are imported

def login_post(request):
    if request.method == 'POST' and 'submit' in request.POST:
        u = request.POST.get('uname')
        p = request.POST.get('pwd')

        user = authenticate(request, username=u, password=p)

        if user is not None:
            login(request, user)
            try:
                if user.groups.filter(name='Admin').exists():
                    return HttpResponse("<script>alert('Logged in as Admin');window.location='/adminhome';</script>")

                elif user.groups.filter(name='College').exists():
                    request.session['clid'] = user.id
                    college = College.objects.get(user_id=user.id)
                    if college.status == 'accepted':
                        request.session['cid'] = college.id
                        return HttpResponse("<script>alert('Logged in as College');window.location='/collegehome';</script>")
                    else:
                        return HttpResponse("<script>alert('Sorry you can't login');window.location='/';</script>")

                    
                elif user.groups.filter(name='Student').exists():
                    request.session['slid'] = user.id
                    student = UserProfile.objects.get(user_id=user.id)
                    request.session['sid'] = student.id
                    return HttpResponse("<script>alert('Logged in as Student');window.location='/guidehome';</script>")
                
                elif user.groups.filter(name='Parent').exists():
                    request.session['plid'] = user.id
                    parent = Parent.objects.get(user_id=user.id)
                    request.session['pid'] = parent.id
                    return HttpResponse("<script>alert('Logged in as Parent');window.location='/collegehome';</script>")

                else:
                    return HttpResponse("<script>alert('Unable to login');window.location='/login';</script>")

            except Exception as e:
                print("Login error:", e)
                return HttpResponse("<script>alert('Error during login process');window.location='/login';</script>")
        else:
            return HttpResponse("<script>alert('Invalid username or password');window.location='/login';</script>")

    return render(request, 'login.html')

# def login_post(request):
#  if 'submit' in request.POST:
#         u=request.POST['uname']
#         p=request.POST['pwd']
#         o=authenticate(request, username=u, password=p)
#         login(request,o)
#         if o.groups.filter(name='Admin').exists():
#             print('iiiiiiiiiiiiiiiiiiiiiiiii')
#             return HttpResponse("<script>alert('Logged in as admin');window.location='/adminhome';</script>")

#  return render(request, 'login.html')

#Admin
#VIEW
def auser(request):
    o=UserProfile.objects.all()
    return render(request, 'Admin/auser.html',{'o':o})

def acollege(request):
    o=College.objects.all()
    return render(request, 'Admin/acollege.html',{'o':o})

def acollegeacc(request,id):
    o=College.objects.get(id=id)
    l=User.objects.get(id=o.user_id)
    l.groups.add(Group.objects.get(name='College'))
    l.save()
    o.status='accepted'
    o.save()
    return HttpResponse("<script>alert('College Accepted');window.location='/acollege';</script>")

def acollegerej(request,id):
    o=College.objects.get(id=id)
    o.status='rejected'
    o.save()
    return HttpResponse("<script>alert('College Rejected');window.location='/acollege';</script>")

def acollegeblock(request,id):
    o=College.objects.get(id=id)
    o.status='blocked'
    o.save()
    return HttpResponse("<script>alert('College Blocked');window.location='/acollege';</script>")

def acollegeunb(request,id):
    o=College.objects.get(id=id)
    o.status='unblocked'
    o.save()
    return HttpResponse("<script>alert('College Unblocked');window.location='/acollege';</script>")

# def auseracc(request,id):
#     o=UserProfile.objects.get(id=id)
#     o.status='accepted'
#     o.save()
#     l=User.objects.get(id=o.user.pk)
#     l.groups.add(Group.objects.get(name='Student'))
#     return HttpResponse("<script>alert('Accepted');window.location='/auser';</script>")

# views.py
from django.shortcuts import render, redirect, get_object_or_404
  # adjust to your model name

def auseracc(request, id):
    user = get_object_or_404(UserProfile, id=id)
    user.status = "accepted"
    user.save()
    return HttpResponse("<script>alert('Student details marked as accepted');window.location='/auser';</script>")

def auserrej(request,id):
    o=UserProfile.objects.get(id=id)
    o.status='rejected'
    o.save()
    return HttpResponse("<script>alert('College Rejected');window.location='/acollege';</script>")

def auserblock(request,id):
    o=UserProfile.objects.get(id=id)
    o.status='blocked'
    o.save()
    return HttpResponse("<script>alert('College Blocked');window.location='/acollege';</script>")

def auserunb(request,id):
    o=UserProfile.objects.get(id=id)
    o.status='unblocked'
    o.save()
    return HttpResponse("<script>alert('College Unblocked');window.location='/acollege';</script>")

def anotification(request):
    o=Notification.objects.all()
    if 'submit' in request.POST:
        n=request.POST['n']
        d=request.POST['d']
        q=Notification(notification=n, details=d, date=timezone.now())
        q.save()
        return HttpResponse("<script>alert('Notification send');window.location='/anotification';</script>")

    return render(request, 'Admin/anotification.html',{'o':o})

def acomplaint(request):
    o=Complaint.objects.all()
    if 'submit' in request.POST:
        r=request.POST['r']
        id=request.POST['id']
        q=Complaint.objects.get(id=id)
        q.reply=r
        q.save()
        return HttpResponse("<script>alert('Reply send');window.location='/acomplaint';</script>")
    return render(request, 'Admin/acomplaint.html',{'o':o})


def adepartments(request):
    o=Department.objects.all()
    if 'submit' in request.POST:
        n=request.POST['n']
        d=request.POST['d']
        q=Department(details=d, department=n)
        q.save()
        return HttpResponse("<script>alert('Department added successfully');window.location='/adepartments';</script>")
    return render(request, 'Admin/adepartments.html',{'o':o})

def adepartmentsedit(request,id):
    o=Department.objects.all()
    z=Department.objects.get(id=id)
    if 'update' in request.POST:
        z.department=request.POST['n']
        z.details=request.POST['d']
        z.save()
        return HttpResponse("<script>alert('Department details updated successfully');window.location='/adepartments';</script>")
    return render(request, 'Admin/adepartments.html',{'o':o,'z':z})

def adepartmentdelete(request,id):
    z=Department.objects.get(id=id)
    z.delete()
    return HttpResponse("<script>alert('Department deleted successfully');window.location='/adepartments';</script>")


def acourse(request):
    s=Department.objects.all()
    o=Course.objects.all()
    if 'submit' in request.POST:
        id=request.POST['id']
        c=request.POST['c']
        q=Course(department_id=id, course=c)
        q.save()
        return HttpResponse("<script>alert('Course added successfully');window.location='/acourse';</script>")
    return render(request, 'Admin/acourse.html',{'o':o,'s':s})

def acourseedit(request,id):
    s=Department.objects.all()

    o=Course.objects.all()
    z=Course.objects.get(id=id)
    if 'update' in request.POST:
        z.department_id=request.POST['id']
        z.course=request.POST['c']
        z.save()
        return HttpResponse("<script>alert('Course details updated successfully');window.location='/acourse';</script>")
    return render(request, 'Admin/acourse.html',{'o':o,'z':z,'s':s})

def acoursedelete(request,id):
    z=Course.objects.get(id=id)
    z.delete()
    return HttpResponse("<script>alert('Course deleted successfully');window.location='/acourse';</script>")



def aarticles(request):
    s=Article.objects.all()
    o=Article.objects.all()
    if 'submit' in request.POST:
        id=request.POST['id']
        c=request.POST['c']
        q=Article(title=id, subject=c, date=timezone.now())
        q.save()
        return HttpResponse("<script>alert('Article added successfully');window.location='/aarticles';</script>")
    return render(request, 'Admin/aarticles.html',{'o':o,'s':s})

def aarticlesedit(request,id):
    o=Article.objects.all()
    z=Article.objects.get(id=id)
    if 'update' in request.POST:
        z.title=request.POST['id']
        z.subject=request.POST['c']
        z.save()
        return HttpResponse("<script>alert('Article details updated successfully');window.location='/aarticles';</script>")
    return render(request, 'Admin/aarticles.html',{'o':o,'z':z})

def aaarticlesdelete(request,id):
    z=Article.objects.get(id=id)
    z.delete()
    return HttpResponse("<script>alert('Article deleted successfully');window.location='/aarticles';</script>")


def arequest(request):
    o=CourseRequest.objects.all()
    return render(request, 'Admin/arequest.html',{'o':o})

def arequestacc(request,id):
    c=CourseRequest.objects.get(id=id)
    c.status = 'accepted'
    c.save()
    return HttpResponse("<script>alert('Course request accepted successfully');window.location='/arequest';</script>")

def arequestrej(request,id):
    o=CourseRequest.objects.get(id=id)
    o.status = 'rejected'
    o.save()
    return HttpResponse("<script>alert('Course request rejected successfully');window.location='/arequest';</script>")

#College

from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.core.files.storage import FileSystemStorage
from django.db import IntegrityError
from django.shortcuts import render


def creg(request):
    error_message = None
    if 'submit' in request.POST:
        name = request.POST['name']
        place = request.POST['place']
        email = request.POST['email']
        phone = request.POST['phone']
        uname = request.POST['uname']
        pwd = request.POST['pwd']

        proof_file = request.FILES['proof']
        fs = FileSystemStorage()
        saved_path = fs.save(proof_file.name, proof_file)

        try:
            u = User.objects.create(username=uname, password=make_password(pwd))
            college = College(
                user=u,
                name=name,
                place=place,
                email=email,
                phone=phone,
                proof=saved_path
            )
            college.save()
            return HttpResponse("<script>alert('College added successfully');window.location='/login';</script>")

        except IntegrityError:
            error_message = "⚠️ Username already exists, please choose another one."

    return render(request, 'College/reg.html', {"error_message": error_message})


def cviewprofile(request):
    id=request.session['cid']
    z=College.objects.get(id=id)
    return render(request, 'College/cviewprofile.html',{'z':z})

def cupdateprofile(request):
    id=request.session['cid']
    z=College.objects.get(id=id)
    if 'update' in request.POST:
        z.name = request.POST['name']
        z.place = request.POST['place']
        z.email = request.POST['email']
        z.phone = request.POST['phone']
        if 'proof' in request.FILES:
            proof_file = request.FILES['proof']
            fs = FileSystemStorage()
            saved_path = fs.save(proof_file.name, proof_file)
            z.proof = saved_path
        z.save()
        return HttpResponse("<script>alert('Profile updated successfully');window.location='/cviewprofile';</script>")

    return render(request, 'College/updateprofile.html',{'z':z})

def ccourse(request):
    cid=request.session.get('cid')
    print(cid,'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
    s=CourseRequest.objects.filter(college_id=cid)
    u=s.values_list('course_id',flat=True)
    q=Course.objects.all().exclude(id__in =u)
    if 'submit' in request.POST:
        selected_course = request.POST['courseid']
        s=CourseRequest(date=timezone.now(),status='pending',college_id=cid,course_id=selected_course)
        s.save()
        return HttpResponse("<script>alert('Course requeste sent successfully');window.location='/ccourse';</script>")
    return render(request, 'College/ccourse.html',{'q':q})

def cresults(request):
    return HttpResponse("<script>alert('Section on progress');window.location='/ccourse';</script>")


def crequeststatus(request):
    cid=request.session.get('cid')
    o=CourseRequest.objects.filter(college_id=cid)
    print(o,cid)
    return render(request, 'College/crequeststatus.html',{'o':o})

def cdataset(request):
    o=Dataset.objects.all()
    if 'submit' in request.POST:
        question=request.POST['question']
        answer=request.POST['answer']
        q=Dataset(question=question,answer=answer)
        q.save()
        return HttpResponse("<script>alert('Article added successfully');window.location='/cdataset';</script>")
    return render(request, 'College/cdataset.html',{'o':o})

def cdatasetedit(request,id):
    o=Dataset.objects.all()
    z=Dataset.objects.get(id=id)
    if 'update' in request.POST:
        z.question=request.POST['question']
        z.answer=request.POST['answer']
        z.save()
        return HttpResponse("<script>alert('Article details updated successfully');window.location='/cdataset';</script>")
    return render(request, 'College/cdataset.html',{'o':o,'z':z})

def cdatasetdelete(request,id):
    z=Dataset.objects.get(id=id)
    z.delete()
    return HttpResponse("<script>alert('Article deleted successfully');window.location='/cdataset';</script>")












from django.shortcuts import render
from django.http import HttpResponse
from .models import LastAdmissionDetails, College, CourseRequest

def add_last_admission(request):
    cid = request.session.get('cid')   # assuming you store college id in session
    p=CourseRequest.objects.filter(college_id=cid)

    college = College.objects.get(id=cid)
    course_requests = CourseRequest.objects.all()   # to show in a dropdown

    if 'submit' in request.POST:
        course_id = request.POST['course_request']
        marks_starting = request.POST['marks_starting']
        marks_ending = request.POST['marks_ending']

        course_request = CourseRequest.objects.get(id=course_id)

        new_record = LastAdmissionDetails(
            college=college,
            course_request=course_request,
            marks_starting=marks_starting,
            marks_ending=marks_ending
        )
        new_record.save()

        return HttpResponse("<script>alert('Admission details added successfully');window.location='/add_last_admission';</script>")

    records = LastAdmissionDetails.objects.filter(college=college)
    return render(request, 'College/admark.html', {
        'records': records,
        'course_requests': p
    })




def edit_last_admission(request,id):
    cid = request.session.get('cid')   # assuming you store college id in session
    p=CourseRequest.objects.filter(college_id=cid)

    college = College.objects.get(id=cid)
    course_requests = CourseRequest.objects.all()   # to show in a dropdown

    l=LastAdmissionDetails.objects.get(id=id)

    if 'update' in request.POST:
        l.course_request = request.POST['course_request']
        l.marks_starting = request.POST['marks_starting']
        l.marks_ending = request.POST['marks_ending']
        l.save()

        return HttpResponse("<script>alert('Admission details edited successfully');window.location='/add_last_admission';</script>")

    records = LastAdmissionDetails.objects.filter(college=college)
    return render(request, 'College/admark.html', {
        'records': records,
        'course_requests': p,
        'z':l,
    })


def delete_last_admission(request,id):
        z=LastAdmissionDetails.objects.get(id=id)
        z.delete()
        return HttpResponse("<script>alert('Admission details deleted successfully');window.location='/add_last_admission';</script>")



#MANAGE
def cdataset(request):
    c=Course.objects.all()
    cid=request.POST.get('cid')
    o=Dataset.objects.all()
    if 'submit' in request.POST:
        question=request.POST['question']
        answer=request.POST['answer']
        q=Dataset(question=question,answer=answer,course_id=cid)
        q.save()
        return HttpResponse("<script>alert('Article added successfully');window.location='/cdataset';</script>")
    return render(request, 'College/cdataset.html',{'o':o,'c':c})

def cdatasetedit(request,id):
    o=Dataset.objects.all()
    z=Dataset.objects.get(id=id)
    if 'update' in request.POST:
        z.question=request.POST['question']
        z.answer=request.POST['answer']
        z.save()
        return HttpResponse("<script>alert('Article details updated successfully');window.location='/cdataset';</script>")
    return render(request, 'College/cdataset.html',{'o':o,'z':z})

def cdatasetdelete(request,id):
    z=Dataset.objects.get(id=id)
    z.delete()
    return HttpResponse("<script>alert('Article deleted successfully');window.location='/cdataset';</script>")

def cnotifications(request):
    o=Notification.objects.all()
    return render(request, 'College/cnotifications.html',{'o':o})



#Student - Flutter  



# def auser(request):
#     o=UserProfile.objects.all()
#     return render(request, 'Admin/User.html',{'o':o})
def getcourses(request):
    q = Course.objects.all()
    data = []
    for i in q:
        data.append({
            'cn': i.course,
            'department': i.department.department,
            'cid': i.pk,
        })
    return JsonResponse({'status': 'success', 'data': data})

def sreg(request):
        username = request.POST['uname']
        pwd=request.POST['pwd']
        name = request.POST['name']
        gender = request.POST['gender']
        place = request.POST['place']
        post = request.POST['post']
        pin = request.POST['pin']
        course = request.POST['course_id']
        email = request.POST['email']
        phone = request.POST['phone']
        image = request.FILES.get('image')
        fs=FileSystemStorage()
        saved_path=fs.save(image.name,image)

        u=User.objects.create(username=username, password=make_password(pwd))
        u.groups.add(Group.objects.get(name='Student'))
        c=UserProfile(
            name=name,
            gender=gender,
            place=place,
            post=post,
            pin=pin,
            email=email,
            phone=phone,
            image=saved_path,
            status='pending',
            course_id=course,
            user_id=u.id)
        c.save()
        response={
            'status':'success',
        }
        return JsonResponse(response)

from django.contrib.auth.models import User, Group
from django.contrib.auth.hashers import make_password
from django.core.files.storage import FileSystemStorage
from django.http import JsonResponse
from .models import Parent, UserProfile

# def preg(request):
#     data = []
#     d = UserProfile.objects.all()
#     for i in d:
#         data.append({
#             'id': i.pk,
#             'name': i.name,
#             'place': i.place,
#             'email': i.email,
#             'photo': i.image.name,
#         })

#     username = request.POST['uname']
#     pwd = request.POST['pwd']
#     name = request.POST['name']
#     place = request.POST['place']
#     email = request.POST['email']
#     phone = request.POST['phone']
#     sid = request.POST['sid']  # student id coming from Flutter

#     image = request.FILES.get('image')
#     fs = FileSystemStorage()
#     saved_path = fs.save(image.name, image) if image else None

#     # Create Parent User
#     u = User.objects.create(username=username, password=make_password(pwd))
#     u.groups.add(Group.objects.get(name='Parent'))

#     # Save Parent Profile with correct student id
#     c = Parent(
#         name=name,
#         place=place,
#         email=email,
#         phone=phone,
#         proof=saved_path,
#         student_id=sid,   # ✅ student id from Flutter
#         user_id=u.id      # ✅ parent user id
#     )
#     c.save()

#     response = {
#         'status': 'success',
#         'students': data,
#     }
#     return JsonResponse(response)


from django.http import JsonResponse
from .models import UserProfile

from django.http import JsonResponse
from .models import UserProfile  # adjust to your model location

from django.http import JsonResponse
from django.core.files.storage import FileSystemStorage
from django.contrib.auth.models import User, Group
from django.contrib.auth.hashers import make_password
from .models import UserProfile, Parent

def get_students(request):
    data = []
    d = UserProfile.objects.all()
    for i in d:
        data.append({
            'id': i.pk,
            'name': i.name,
            'place': i.place,
            'email': i.email,
            'photo': i.image.name if i.image else '',
        })
    return JsonResponse({'status': 'success', 'students': data})


def preg(request):
    username = request.POST['uname']
    pwd = request.POST['pwd']
    name = request.POST['name']
    place = request.POST['place']
    email = request.POST['email']
    phone = request.POST['phone']
    sid = request.POST['sid']

    image = request.FILES.get('proof_pdf')
    saved_path = None
    if image:
        fs = FileSystemStorage()
        saved_path = fs.save(image.name, image)

    u = User.objects.create(username=username, password=make_password(pwd))
    u.groups.add(Group.objects.get(name='Parent'))
    print(username, pwd,'iiiiiiiiiiiiiiiiiiiiiiiiiiii')

    c = Parent(
        name=name,
        place=place,
        email=email,
        phone=phone,
        proof=saved_path,
        student_id=sid,
        user_id=u.id
    )
    c.save()

    return JsonResponse({'status': 'success'})

def viewscollege(request):
    data=[]
    s=College.objects.all()

    for i in s:
        data.append({
            'id':i.pk,
            'n':i.name,
            'p':i.place,
            'e':i.email,
            'ph':i.phone,
            'pr':i.proof.name,
        })
        print(data)

    response={
        'status':'success',
        'data':data,

    }

    return JsonResponse(response)

def viewsuggestion(request):
    cid = request.POST['cid']
    data=[]
    s=Suggestion.objects.filter(college_id=cid)

    for i in s:
        data.append({
            's':i.suggestion,
            'd':i.details,
            'sn':i.student.name,
        })
        print(data)

    response={
        'status':'success',
        'data':data,
    }

    return JsonResponse(response)

def sendsuggestion(request):
    u=request.POST['uid']
    c=request.POST['cid']
    s=request.POST['sug']
    d=request.POST['det']

    a=Suggestion(suggestion=s,details=d,student_id=u,college_id=c)
    a.save()
    response={
        'status':'success'
    }
    return JsonResponse(response)



def viewcomp(request):
    data=[]
    u=request.POST['uid']
    c=Complaint.objects.filter(user_id=u)

    for i in c:
        data.append({
            'c':i.complaint,
            'r':i.reply,
            'd':i.date.strftime("%Y-%m-%d %H:%M"),
        })
        print(data)

    response={
        'status':'success',
        'data':data,

    }

    return JsonResponse(response)

def sendcomplaint(request):
    u=request.POST['uid']
    c=request.POST['c']
    a=Complaint(complaint=c, date=timezone.now(),reply='pending',user_id=u)
    a.save()
    response={
        'status':'success'
    }
    return JsonResponse(response)
def applogin(request):
    uname = request.POST.get('uname')
    pwd = request.POST.get('pwd')

    response = { 'status': 'Invalid Username or Password' }  # default response

    try:
        user = authenticate(username=uname, password=pwd)
        if user:
            if user.groups.filter(name='Student').exists():
                # ✅ Check UserProfile for Students
                try:
                    u = UserProfile.objects.get(user_id=user.id)
                    if u.status == 'accepted':
                        login(request, user)
                        response = {
                            'status': 'welcome to home screen',
                            'type': 'Student',
                            'uid': u.id,
                            'uimg': u.image.name,
                        }
                    else:
                        response = { 'status': 'Account not yet verified by the admin' }
                except UserProfile.DoesNotExist:
                    response = { 'status': 'Student profile not found' }

            elif user.groups.filter(name='Parent').exists():
                # ✅ Directly check Parent table
                try:
                    p = Parent.objects.get(user_id=user.id)
                    login(request, user)
                    response = {
                        'status': 'welcome to the home screen',
                        'type': 'Parent',
                        'uid': p.id,
                    }
                except Parent.DoesNotExist:
                    response = { 'status': 'Parent profile not found' }

    except Exception as e:
        print("Login error:", e)   # debug log

    return JsonResponse(response)


def particle(request):
    data=[]
    u=request.POST['uid']
    c=Article.objects.all()

    for i in c:
        data.append({
            'c':i.title,
            'r':i.subject,
            'd':i.date,
    
        })

    response={
        'status':'success',
        'data': data
    }
    print(data)
    return JsonResponse(response)

from django.http import JsonResponse
from django.core.files.storage import FileSystemStorage
from .models import UserProfile

from django.http import JsonResponse
from .models import UserProfile

def studentprofile(request):
    uid = request.POST.get('uid')
    try:
        student = UserProfile.objects.get(id=uid)
        data = [{
            'name': student.name,
            'gender': student.gender,
            'place': student.place,
            'post': student.post,
            'pin': student.pin,
            'phone': student.phone,
            'email': student.email,
            'image': student.image.name,
        }]
        return JsonResponse({'status': 'success', 'data': data})
    except UserProfile.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Student not found'})

def editsreg(request):
    try:
        uid = request.POST['uid']
        student = UserProfile.objects.get(id=uid)

        student.name = request.POST['name']
        student.gender = request.POST['gender']
        student.place = request.POST['place']
        student.post = request.POST['post']
        student.pin = request.POST['pin']
        student.phone = request.POST['phone']
        student.email = request.POST['email']

        if 'image' in request.FILES:
            image = request.FILES['image']
            fs = FileSystemStorage()
            saved_path = fs.save(image.name, image)
            student.image = saved_path

        student.save()
        print(uid)
        return JsonResponse({'status': 'success', 'message': 'Profile updated successfully'})

    except UserProfile.DoesNotExist:
        return JsonResponse({'status': 'failed', 'message': 'Student not found'})
    except Exception as e:
        return JsonResponse({'status': 'failed', 'message': str(e)})


def parentprofile(request):
    uid=request.POST.get('uid')
    data=[]

    r= Parent.objects.get(id=uid)
    data.append({
        'n':r.name,
        'ph':r.phone,
        'e':r.email,
        'pl':r.place,
        's':r.student.name,
        'sid':r.student.pk,
        'proof_pdf':r.proof.name,
    })

    responce ={
        'data': data
    }
    return JsonResponse(responce)

def editpreg(request):
        data=[]
        d=UserProfile.objects.all()
        for i in d:
            data.append({
                'sname':i.name,
                'place':i.place,
            })
        
        uid = request.POST['uid']
        h=Parent.objects.get(id=uid)
        h.name = request.POST['name']
        h.place = request.POST['place']
        h.email = request.POST['email']
        h.phone = request.POST['phone']
        try:
                    h.student_id=request.POST['sid']
        except:
            pass
        try:
            image = request.FILES.get('proof_pdf')
            fs=FileSystemStorage()
            saved_path=fs.save(image.name,image)
            h.proof=saved_path
        except:
            pass
        h.save()
        response={
            'status':'success',
            'students':data
        }
        return JsonResponse(response)




def pstudent(request):
    data=[]
    u=request.POST['uid']
    c=Parent.objects.get(id=u)
    student=UserProfile.objects.get(id=c.student.pk)
    data.append({
            'name': student.name,
            'gender': student.gender,
            'place': student.place,
            'post': student.post,
            'pin': student.pin,
            'phone': student.phone,
            'email': student.email,
            'image': student.image.name if student.image else None,
        })

    response={
        'status':'success',
        'data': data
    }
    print(data)
    return JsonResponse(response)

def p_change_password(request):
    uid = request.POST.get('uid')
    p=Parent.objects.get(id=uid)
    current_password = request.POST.get('textfield')
    new_password = request.POST.get('textfield2')
    confirm_password = request.POST.get('textfield3')

    user = User.objects.get(id=p.user.pk)
    print(user,uid,'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
    print(f"UID: {uid}, User: {user.username}, DB Password Hash: {user.password}")
    print(f"Entered current password: {current_password}")

    if check_password(current_password, user.password):
        if new_password == confirm_password:
            user.set_password(new_password)
            user.save()
            response = {'message': 'Password changed successfully'}
        else:
            response = {'message': 'New and Confirm password do not match.'}
    else:
        response = {'message': 'Current password is incorrect.'}

    return JsonResponse(response)

def s_change_password(request):
    uid = request.POST.get('uid')
    p=UserProfile.objects.get(id=uid)
    current_password = request.POST.get('old_password')
    new_password = request.POST.get('new_password')
    confirm_password = request.POST.get('conf_pwd')

    user = User.objects.get(id=p.user.pk)
    print(user,uid,'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
    print(f"UID: {uid}, User: {user.username}, DB Password Hash: {user.password}")
    print(f"Entered current password: {current_password}")

    if check_password(current_password, user.password):
        if new_password == confirm_password:
            user.set_password(new_password)
            user.save()
            response = {'message': 'Password changed successfully'}
        else:
            response = {'message': 'New and Confirm password do not match.'}
    else:
        response = {'message': 'Current password is incorrect.'}

    return JsonResponse(response)

def pcourse(request):
    data = []
    pid= request.POST['uid']
    p=Parent.objects.get(id=pid)
    s=UserProfile.objects.get(id=p.student.pk)
    i=Course.objects.get(id=s.course.pk)

    data.append({
            'cn':i.course,
            'id': i.pk,
            'd':i.department.department,
        })
    response = {
        'data':data
    }
    print(data)
    return JsonResponse(response)


# def chatbot_view(request):
#     question = request.POST.get('question')
#     correct_answer = request.POST.get('correct_answer')
#     user_answer = request.POST.get('user_answer')

#     score = gpt_score_answer(user_answer, question, correct_answer)
#     print(f"Score for user answer: {score}")

#     response = {
#         'score': score
#     }
#     return JsonResponse(response)







# from django.http import JsonResponse
# import json

# def chatbot_view(request):
#  m=0
#  if m<4:
#     c=Course.objects.all()
#     data=[]
#     for i in c:
#         data.append({
#             'course_name':i.course,
#             'course_id':i.pk,
#             'department name':i.department.department,
#         })
#     course_list=gpt_course_classifier(data)

#     for key, value_list in course_list.items():
#         k=value_list
#         cid=random.choice(k)
#         d=Dataset.objects.filter(course_id=cid).values_list('id',flat=True)
#         did=random.choice(d)
#         dataset=Dataset.objects.get(id=did)
#         response={
#             'q':dataset.question
#         }
#         if request.method != 'POST':
#             return JsonResponse({'error': 'Invalid request method'}, status=405)
#         try:
#             # Parse JSON body
#             body = json.loads(request.body.decode('utf-8'))
#             uid = body.get('uid')
#             question = body.get('question')
#             correct_answer = dataset.answer
#             user_answer = body.get('user_answer')
#         except json.JSONDecodeError:
#             return JsonResponse({'error': 'Invalid JSON'}, status=400)

#         # Validate all required fields
#         if not all([uid, question, correct_answer, user_answer]):
#             return JsonResponse({'error': 'Missing required parameters'}, status=400)
        
#         # Call your scoring function
#         score = gpt_score_answer(user_answer, question, correct_answer)
#         print(f"Score for user answer: {score}")
#         q=ChatBot( dataset_id =dataset.pk, answer=user_answer, date=datetime.now(),user_id=uid, score=score)
#         q.save()
#         m=m+1
#  elif m==4:
#     a=Course.objects.all()
#     for n in a:
#         v=ChatBot.objects.filter(dataset__course_id=a).values_list('score',flat=True)
#         if sum(v)>total:
#             total=sum(v)
#             s=n.department.pk
#         f=Dataset.objects.filter(course__department_id=s).values_list('id',flat=True)
#         p=random.sample(f,6)
#         for z in p:
#             dataset=Dataset.objects.get(id=did)
#             response={
#                 'q':dataset.question
#             }
#             if request.method != 'POST':
#                 return JsonResponse({'error': 'Invalid request method'}, status=405)
#             try:
#                 # Parse JSON body
#                 body = json.loads(request.body.decode('utf-8'))
#                 uid = body.get('uid')
#                 question = body.get('question')
#                 correct_answer = dataset.answer
#                 user_answer = body.get('user_answer')
#             except json.JSONDecodeError:
#                 return JsonResponse({'error': 'Invalid JSON'}, status=400)

#             # Validate all required fields
#             if not all([uid, question, correct_answer, user_answer]):
#                 return JsonResponse({'error': 'Missing required parameters'}, status=400)
            
#             # Call your scoring function
#             score = gpt_score_answer(user_answer, question, correct_answer)
#             print(f"Score for user answer: {score}")
#             q=ChatBot( dataset_id =dataset.pk, answer=user_answer, date=datetime.now(),user_id=uid, score=score)
#             q.save()
#             m=m+1

#     return JsonResponse(response)


# def update_phase(user_id):
#     total_answers = ChatBot.objects.filter(user_id=user_id).count()

#     if total_answers == 0:
#         return 1
#     if total_answers % 10 == 0:
#         return 4
#     elif total_answers % 10 == 1:
#         return 1
#     elif total_answers % 5 == 0:
#         return 2
#     elif str(total_answers).endswith("8"):
#         return 3
#     else:
#         return user_phase.get(user_id, 1)


# # chatbot_views.py
# import random
# from django.utils import timezone
# from django.http import JsonResponse
# from .models import Dataset, ChatBot, Course

# # Phase tracking per user (in memory for now)
# user_phase = {}
# user_scores = {}

# def get_next_question(request):
#     user_id = request.GET.get("user_id")     
#     user = request.user
#     phase = update_phase(user_id)

#     if phase == 1:
#         # Random question from any course
#         question = Dataset.objects.order_by('?').first()

#     elif phase == 2:
#         # Find top scoring course
#         if user.id in user_scores and user_scores[user.id]:
#             top_course_id = max(user_scores[user.id], key=user_scores[user.id].get)
#             question = Dataset.objects.filter(course_id=top_course_id).order_by('?').first()
#         else:
#             question = Dataset.objects.order_by('?').first()

#     elif phase == 3:
#         # Deep dive into top course (only remaining questions)
#         if user.id in user_scores and user_scores[user.id]:
#             top_course_id = max(user_scores[user.id], key=user_scores[user.id].get)
#             answered_questions = ChatBot.objects.filter(user=user, question__isnull=False).values_list('question', flat=True)
#             remaining = Dataset.objects.filter(course_id=top_course_id).exclude(question__in=answered_questions)
#             if remaining.exists():
#                 question = remaining.order_by('?').first()
#         else:
#             question = Dataset.objects.order_by('?').first()
#     elif phase == 4:
#                 data = (
#                     ChatBot.objects.filter(user_id=user.id)
#                     .values("dataset__course_id")
#                     .annotate(total_score=Sum("score"))
#                     .order_by("-total_score")
#                 )
#                 top_course_id = data[0]["dataset__course_id"]
#                 c=Course.objects.get(id=top_course_id) 
#                 print(c)            

#                 return JsonResponse({"message": f"All questions completed! The course recommended for you is {c.course}"})
        

#     return JsonResponse({
#         "question": question.question,
#         "course": question.course.course,
#         "course_id": question.pk,
#         "phase": phase,
#     })
from django.db.models import Sum

user_phase = {}
user_scores = {}
def update_phase(user_id):
    user_id = int(user_id)
    total_answers = ChatBot.objects.filter(user_id=user_id).count()

    if total_answers == 0:
        return 1
    if total_answers % 10 == 0:
        return 4
    elif total_answers % 10 == 1:
        return 1
    elif total_answers % 5 == 0:
        return 2
    elif str(total_answers).endswith("8"):
        return 3
    else:
        return user_phase.get(user_id, 1)

def get_next_question(request):
    user_id = request.GET.get("user_id")
    if not user_id:
        return JsonResponse({"error": "user_id required"}, status=400)
    user_id = int(user_id)

    phase = update_phase(user_id)
    user_phase[user_id] = phase  # ✅ save phase state

    # All answered dataset IDs for this user
    answered_ids = ChatBot.objects.filter(user_id=user_id).values_list("dataset_id", flat=True)

    if phase == 1:
        # Pick a random question excluding already answered
        question = Dataset.objects.exclude(id__in=answered_ids).order_by("?").first()

    elif phase == 2:
        # Get top 2 courses by score
        data = (
            ChatBot.objects.filter(user_id=user_id)
            .values("dataset__course_id")
            .annotate(total_score=Sum("score"))
            .order_by("-total_score")[:2]  # ✅ top 2
        )
        if data:
            # Randomly pick from top 2 courses
            import random
            chosen = random.choice(data)
            top_course_id = chosen["dataset__course_id"]

            # Pick a random question from that course excluding answered
            question = Dataset.objects.filter(course_id=top_course_id).exclude(id__in=answered_ids).order_by("?").first()
        else:
            question = Dataset.objects.exclude(id__in=answered_ids).order_by("?").first()

    elif phase == 3:
        # Get top course
        data = (
            ChatBot.objects.filter(user_id=user_id)
            .values("dataset__course_id")
            .annotate(total_score=Sum("score"))
            .order_by("-total_score")
        )
        if data:
            top_course_id = data[0]["dataset__course_id"]
            remaining = Dataset.objects.filter(course_id=top_course_id).exclude(id__in=answered_ids)
            if remaining.exists():
                question = remaining.order_by("?").first()
            else:
                c = Course.objects.get(id=top_course_id)
                return JsonResponse({
                    "message": f"All questions completed! The course recommended for you is {c.course}",
                    "phase": 4
                })
        else:
            question = Dataset.objects.exclude(id__in=answered_ids).order_by("?").first()

    elif phase == 4:
        data = (
            ChatBot.objects.filter(user_id=user_id)
            .values("dataset__course_id")
            .annotate(total_score=Sum("score"))
            .order_by("-total_score")
        )
       
        if data:
            top_score = data[0]["total_score"]

            top_course_id = data[0]["dataset__course_id"]
            c = Course.objects.get(id=top_course_id)
            course_name=c.course
            q=gpt_job_recomendation(course_name,top_score)
            print(q,'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv')
            return JsonResponse({
                     "message": f"All questions completed! The course recommended for you is {c.course}.",
                     "job_recommendation": q,
                     "phase": 4,
})

        else:
            return JsonResponse({"message": "Not enough data for recommendation", "phase": 4})

    if not question:
        return JsonResponse({"error": "No questions available"}, status=404)

    return JsonResponse({
        "question": question.question,
        "course": question.course.course,
        "dataset_id": question.pk,
        "phase": phase,
    })

# views.py
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime
from .models import ChatBot, Dataset
from .Geminiapi import gpt_job_recomendation, gpt_score_answer  # Import the scoring function

@api_view(['POST'])
def submit_answer(request):

    try:
        user_id = request.data.get("user_id")
        dataset_id = request.data.get("dataset_id")
        user_answer = request.data.get("user_answer")

        if not all([user_id, dataset_id, user_answer]):
            return Response({"error": "user_id, dataset_id, and user_answer are required"},
                            status=status.HTTP_400_BAD_REQUEST)

        # Fetch question and correct answer from Dataset table
        try:
            dataset = Dataset.objects.get(id=dataset_id)
        except Dataset.DoesNotExist:
            return Response({"error": "Dataset not found"}, status=status.HTTP_404_NOT_FOUND)

        question = dataset.question
        correct_answer = dataset.answer

        # Get score from Gemini API
        score = gpt_score_answer(user_answer, question, correct_answer)

        # Save to ChatBot table
        chatbot_entry = ChatBot(
            user_id=user_id,
            dataset_id=dataset.pk,
            answer=user_answer,
            date=datetime.now(),
            score=score
        )
        chatbot_entry.save()

        return Response({
            "message": "Answer submitted successfully",
            "dataset_id": dataset_id,
            "score": score
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

import pandas as pd
from django.http import JsonResponse
from guidanceapp.Geminiapi import gpt_course_classifier
import mysql.connector
from django.http import JsonResponse
import mysql.connector
import pandas as pd
from guidanceapp.Geminiapi import gpt_course_classifier

# def admission_prediction(request):
#     if request.method != "POST":
#         return JsonResponse({"error": "POST request required"}, status=400)
    
#     data = request.POST
#     try:
#         student_marks = float(data.get("marks"))
#         student_stream = data.get("stream").strip().lower()
#     except (TypeError, ValueError):
#         return JsonResponse({"error": "Invalid marks or stream"}, status=400)

#     db = mysql.connector.connect(
#         host="localhost",
#         user="root",
#         password="",
#         database="CareerGuidanceandCollegeAdmissionChancesPredictionSystem"
#     )
#     cursor = db.cursor(dictionary=True)

#     # Fetch courses
#     cursor.execute("""
#         SELECT c.id as course_id, c.course as course_name, d.department as department_name
#         FROM guidanceapp_course c
#         JOIN guidanceapp_department d ON c.department_id = d.id
#     """)
#     courses = cursor.fetchall()
#     course_list = [{"course_id": c["course_id"], "course_name": c["course_name"]} for c in courses]

#     # Classify courses by stream
#     stream_map = gpt_course_classifier(course_list)
#     if student_stream not in stream_map:
#         return JsonResponse({"error": "Invalid stream entered"}, status=400)

#     allowed_course_ids = stream_map[student_stream]

#     # Fetch last admission data
#     query = """
#         SELECT lad.id, lad.marks_starting, lad.marks_ending, 
#                c.id as course_id, c.course, d.department, col.name
#         FROM guidanceapp_lastadmissiondetails lad
#         JOIN guidanceapp_courserequest cr ON lad.course_request_id = cr.id
#         JOIN guidanceapp_course c ON cr.course_id = c.id
#         JOIN guidanceapp_department d ON c.department_id = d.id
#         JOIN guidanceapp_college col ON cr.college_id = col.id
#     """
#     cursor.execute(query)
#     data = cursor.fetchall()
#     df = pd.DataFrame(data)

#     # Filter courses by stream
#     filtered_df = df[df['course_id'].isin(allowed_course_ids)].copy()
#     if filtered_df.empty:
#         return JsonResponse({"error": "No courses found for this stream"}, status=404)

#     # Prepare available courses
#     unique_courses = filtered_df[['course_id', 'course']].drop_duplicates()
#     courses_list = [{"course_id": row.course_id, "course_name": row.course} 
#                     for row in unique_courses.itertuples(index=False)]

#     # Chance calculation
#     def calculate_chance(row):
#         start = row['marks_starting']
#         end = row['marks_ending']
#         if student_marks >= end:
#             return 100.0
#         elif student_marks >= start:
#             return 90.0 + (student_marks - start) / (end - start) * 10
#         else:
#             diff = start - student_marks
#             return max(0, 70 - diff * 5)

#     filtered_df['chance'] = filtered_df.apply(calculate_chance, axis=1)
#     final_df = filtered_df.sort_values(by="chance", ascending=False)

#     results = [
#         {"college": row['name'], "course": row['course'], "chance": round(row['chance'], 2)}
#         for _, row in final_df.iterrows()
#     ]

#     return JsonResponse({
#         "available_courses": courses_list,   # Important: send available courses
#         "predictions": results
#     })


def admission_prediction(request):
    if request.method != "POST":
        return JsonResponse({"error": "POST request required"}, status=400)
    
    data = request.POST
    try:
        student_marks = float(data.get("marks"))
        student_stream = data.get("stream").strip().lower()
        selected_course_id = data.get("course_id")  # <-- new optional field
    except (TypeError, ValueError):
        return JsonResponse({"error": "Invalid marks or stream"}, status=400)

    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="CareerGuidanceandCollegeAdmissionChancesPredictionSystem"
    )
    cursor = db.cursor(dictionary=True)

    # Fetch courses
    cursor.execute("""
        SELECT c.id as course_id, c.course as course_name, d.department as department_name
        FROM guidanceapp_course c
        JOIN guidanceapp_department d ON c.department_id = d.id
    """)
    courses = cursor.fetchall()
    course_list = [{"course_id": c["course_id"], "course_name": c["course_name"]} for c in courses]

    # Classify courses by stream
    stream_map = gpt_course_classifier(course_list)
    if student_stream not in stream_map:
        return JsonResponse({"error": "Invalid stream entered"}, status=400)

    allowed_course_ids = stream_map[student_stream]

    # Fetch last admission data
    query = """
        SELECT lad.id, lad.marks_starting, lad.marks_ending, 
               c.id as course_id, c.course, d.department, col.name
        FROM guidanceapp_lastadmissiondetails lad
        JOIN guidanceapp_courserequest cr ON lad.course_request_id = cr.id
        JOIN guidanceapp_course c ON cr.course_id = c.id
        JOIN guidanceapp_department d ON c.department_id = d.id
        JOIN guidanceapp_college col ON cr.college_id = col.id
    """
    cursor.execute(query)
    data = cursor.fetchall()
    df = pd.DataFrame(data)

    # Filter courses by stream
    filtered_df = df[df['course_id'].isin(allowed_course_ids)].copy()
    if filtered_df.empty:
        return JsonResponse({"error": "No courses found for this stream"}, status=404)

    # Filter by selected course if provided
    if selected_course_id:
        filtered_df = filtered_df[filtered_df['course_id'] == int(selected_course_id)]
        if filtered_df.empty:
            return JsonResponse({"error": "Selected course not found in this stream"}, status=404)

    # Prepare available courses
    unique_courses = filtered_df[['course_id', 'course']].drop_duplicates()
    courses_list = [{"course_id": row.course_id, "course_name": row.course} 
                    for row in unique_courses.itertuples(index=False)]

    # Chance calculation
    def calculate_chance(row):
        start = row['marks_starting']
        end = row['marks_ending']
        if student_marks >= end:
            return 100.0
        elif student_marks >= start:
            return 90.0 + (student_marks - start) / (end - start) * 10
        else:
            diff = start - student_marks
            return max(0, 70 - diff * 5)

    filtered_df['chance'] = filtered_df.apply(calculate_chance, axis=1)
    final_df = filtered_df.sort_values(by="chance", ascending=False)

    results = [
        {
            "college": row['name'],
            "course": row['course'],
            "chance": round(row['chance'], 2),
            "course_id": row['course_id']  # <-- include course_id
        }
        for _, row in final_df.iterrows()
    ]

    return JsonResponse({
        "available_courses": courses_list,
        "predictions": results
    })


