from django.urls import path

from .views import *

app_name = 'quizes'

urlpatterns = [
    path('<int:test_id>/quizes/defensive_driving/get-answers/', DefensiveDrivingExamAnswerList.as_view()),
]
