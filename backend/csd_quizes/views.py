from django.shortcuts import render

# Create your views here.
from django.views.generic import ListView

from .models import *
from safe_driver.models import StudentTest


class DefensiveDrivingExamAnswerList(ListView):
    model = QuestionAnswer
    template_name = 'csd_quizes/test_exam_answers.html'
    context_object_name = 'answers'

    def get_queryset(self):
        exam = Exam.objects.get(exam_type='defensive_driving')
        test_exam = StudentTestExam.objects.select_related('exam', ).prefetch_related(
            'answer_student_test_exam', 'exam__exam_questions',
        ).get(test_id=self.kwargs.get('test_id'), exam=exam)
        answers = QuestionAnswer.objects.filter(test_exam=test_exam).select_related('question', 'test_exam') \
            .prefetch_related('answers', 'question__correct_choices', 'question__choices', 'question__choice_question'
                              ).all().order_by('question__position')
        return answers
