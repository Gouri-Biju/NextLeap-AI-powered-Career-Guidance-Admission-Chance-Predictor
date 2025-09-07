from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('adminhome/', views.adminhome, name='adminhome'),
    path('login/', views.login_post, name='login'),
    path('register/', views.creg, name='register'),

    path('auser/', views.auser, name='auser'),
    path('auseracc/<int:id>/', views.auseracc, name='auseracc'),
    path('auserrej/<int:id>/', views.auserrej, name='acollegerej'),
    path('auserblock/<int:id>/', views.auserblock, name='acollegeblock'),
    path('auserunb/<int:id>/', views.auserunb, name='acollegeblock'),


    path('acollege/', views.acollege, name='acollege'),
    path('acollegeacc/<int:id>/', views.acollegeacc, name='acollegeacc'),
    path('acollegerej/<int:id>/', views.acollegerej, name='acollegerej'),
    path('acollegeblock/<int:id>/', views.acollegeblock, name='acollegeblock'),
    path('acollegeunb/<int:id>/', views.acollegeunb, name='acollegeblock'),

    path('anotification/', views.anotification, name='anotification'),
    path('cresults/', views.cresults, name='cresults'),

    path('acomplaint/', views.acomplaint, name='acomplaint'),

    path('adepartments/', views.adepartments, name='adepartments'),
    path('adepartmentsedit/<int:id>/', views.adepartmentsedit, name='adepartmentsedit'),
    path('adepartmentdelete/<int:id>/', views.adepartmentdelete, name='adepartmentdelete'),

    path('acourse/', views.acourse, name='acourse'),
    path('acourseedit/<int:id>/', views.acourseedit, name='acourseedit'),
    path('acoursedelete/<int:id>/', views.acoursedelete, name='acoursedelete'),

    path('aarticles/', views.aarticles, name='aarticles'),
    path('aarticlesedit/<int:id>/', views.aarticlesedit, name='aarticlesedit'),
    path('aaarticlesdelete/<int:id>/', views.aaarticlesdelete, name='aaarticlesdelete'),

    path('arequest/', views.arequest, name='arequest'),
    path('arequestacc/<int:id>/', views.arequestacc, name='arequestacc'),
    path('arequestrej/<int:id>/', views.arequestrej, name='arequestrej'),

    path('collegehome/', views.collegehome, name='collegehome'),
    path('ccourse/', views.ccourse, name='ccourse'),

    # College Profile Update
    path('cviewprofile/', views.cviewprofile, name='cviewprofile'),
    path('cupdateprofile/', views.cupdateprofile, name='updateprofile'),

    # Course Requests
    path('crequeststatus/', views.crequeststatus, name='viewcourserequest'),
    path('cnotifications/', views.cnotifications, name='cnotifications'),

    # Dataset Management
    path('cdataset/', views.cdataset, name='cdataset'),
    path('cdatasetedit/<int:id>/', views.cdatasetedit, name='cdatasetedit'),
    path('cdatasetdelete/<int:id>/', views.cdatasetdelete, name='cdatasetdelete'),

    path('get_students/', views.get_students),

    path('api/sreg/', views.sreg, name='sreg'),
    path('api/sendcomplaint/', views.sendcomplaint, name='sendcomplaint'),
    path('api/viewcomp/', views.viewcomp, name='viewcomp'),

    path('api/sendsuggestion/', views.sendsuggestion, name='sendcomplaint'),
    path('api/viewsuggestion/', views.viewsuggestion, name='viewcomp'),

    path('api/applogin/', views.applogin, name='applogin'),
    path('api/particle/', views.particle, name='particle'),
    path('preg/', views.preg, name='preg'),

    path('api/parentprofile', views.parentprofile, name='parentprofile'),
    path('api/editpreg/', views.editpreg, name='editpreg'),
    path('api/studentprofile', views.studentprofile, name='studentprofile'),

    # Edit student profile
    path('api/editsreg/', views.editsreg, name='editsreg'),
    path('api/pstudent/', views.pstudent, name='pstudent'),
    path('api/p_change_password', views.p_change_password, name='p_change_password'),
    path('api/s_change_password', views.s_change_password, name='s_change_password'),
    path('api/studentprofile/', views.studentprofile, name='studentprofile'), 
      # Fetch courses
    path('api/pcourse/', views.pcourse, name='pcourse'),  # Fetch courses
    path('api/change_password/', views.s_change_password, name='change_password'),  # Fetch courses
    path('api/getcourses/', views.getcourses, name='getcourses'),  # Fetch courses
    # path("api/chatbot", views.chatbot_view, name="chatbot"),
    # path('recommend-courses/', views.recommend_courses, name='recommend_courses'),
    # path('predict-admission/', views.predict_admission, name='predict_admission'),
    path('chatbot/get-question/', views.get_next_question, name='get_question'),
    path('chatbot/submit-answer/', views.submit_answer, name='submit_answer'),

    path('api/viewscollege/', views.viewscollege, name='viewscollege'),  # Fetch courses


    # path('api/learn/', views.learn, name='getcourses'),  # Fetch courses
    path('api/admission_prediction/', views.admission_prediction, name='admission_prediction'),
    path('add_last_admission/', views.add_last_admission, name='add_last_admission'),

    path('edit_last_admission/<id>', views.edit_last_admission, name='add_last_admission'),

    path('delete_last_admission/<id>', views.delete_last_admission, name='add_last_admission'),

]