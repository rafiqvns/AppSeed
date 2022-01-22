from django.utils.translation import ugettext_lazy as _
from rest_framework import serializers

from csd_quizes.api.v1.serializers import ExamSerializer, QuestionChoiceSerializer, QuestionOnlySerializer, \
    QuestionSerializer
from csd_quizes.models import *
from safe_driver.image_functions import base64_to_image_content


class StudentTestExamSerializerByTest(serializers.ModelSerializer):
    is_passed = serializers.BooleanField(read_only=True)

    driver_signature = serializers.CharField(required=False, write_only=True)
    evaluator_signature = serializers.CharField(required=False, write_only=True)
    company_rep_signature = serializers.CharField(required=False, write_only=True)

    def to_representation(self, instance):
        response = super(self.__class__, self).to_representation(instance)
        if instance.driver_signature:
            response['driver_signature'] = instance.driver_signature.url
        else:
            response['driver_signature'] = None
        if instance.evaluator_signature:
            response['evaluator_signature'] = instance.evaluator_signature.url
        else:
            response['evaluator_signature'] = None

        if instance.company_rep_signature:
            response['company_rep_signature'] = instance.company_rep_signature.url
        else:
            response['company_rep_signature'] = None

        try:
            response['exam'] = ExamSerializer(instance.exam, read_only=True).data
        except:
            response['exam'] = None

        return response

    def validate(self, attrs):
        request = self.context['request']
        test_id = self.context.get('view').kwargs.get('test_id')
        print(self.instance)
        if not self.instance and 'exam' in attrs:
            if StudentTestExam.objects.filter(test_id=test_id, exam=attrs['exam']):
                # if test_id:
                raise serializers.ValidationError({
                    'exam': _('Exam with this test already exist.')
                })

        return attrs

    class Meta:
        model = StudentTestExam
        fields = '__all__'

        extra_kwargs = {
            'test': {
                'read_only': True
            }
        }

    def update(self, instance, validated_data):
        if 'driver_signature' in validated_data:
            driver_signature = validated_data.pop('driver_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['driver_signature'] = image_content_file
            except Exception as e:
                print(e)

        if 'evaluator_signature' in validated_data:
            driver_signature = validated_data.pop('evaluator_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['evaluator_signature'] = image_content_file
            except Exception as e:
                print(e)

        if 'company_rep_signature' in validated_data:
            driver_signature = validated_data.pop('company_rep_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['company_rep_signature'] = image_content_file
            except Exception as e:
                print(e)
        return super(self.__class__, self).update(instance, validated_data)

    def create(self, validated_data):
        if 'driver_signature' in validated_data:
            driver_signature = validated_data.pop('driver_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['driver_signature'] = image_content_file
            except Exception as e:
                print(e)

        if 'evaluator_signature' in validated_data:
            driver_signature = validated_data.pop('evaluator_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['evaluator_signature'] = image_content_file
            except Exception as e:
                print(e)

        if 'company_rep_signature' in validated_data:
            driver_signature = validated_data.pop('company_rep_signature')
            try:
                image_content_file = base64_to_image_content(driver_signature)
                validated_data['company_rep_signature'] = image_content_file
            except Exception as e:
                print(e)
        return super(self.__class__, self).create(validated_data)


class QuestionAnswerReadSerializer(serializers.ModelSerializer):
    answers = QuestionChoiceSerializer(many=True)
    check_answer = serializers.BooleanField(read_only=True)
    question = QuestionSerializer(read_only=True)

    class Meta:
        model = QuestionAnswer
        fields = '__all__'


class QuestionAnswerSubmitSerializer(serializers.ModelSerializer):
    check_answer = serializers.BooleanField(read_only=True)

    class Meta:
        model = QuestionAnswer
        fields = '__all__'

    def to_representation(self, instance):
        res = super(QuestionAnswerSubmitSerializer, self).to_representation(instance)
        try:
            res['answers'] = QuestionChoiceSerializer(instance.answers, many=True).data
        except Exception as e:
            pass
        try:
            res['question'] = QuestionSerializer(instance.question).data
        except Exception as e:
            pass
        return res

    def validate(self, attrs):
        test_exam = attrs.get('test_exam')
        question = attrs.get('question')
        answers = attrs.get('answers')
        question_choices = question.choice_question.all()
        answer_list = [ans.id for ans in answers]

        if question.question_type == 'single' and len(answers) > 1:
            raise serializers.ValidationError({
                'answers': 'You can only choose one item for this question',
                'question_id': question.pk
            })
        #
        if not question_choices.filter(id__in=answer_list):
            raise serializers.ValidationError({
                'answers': 'Choose the correct choices for the question',
                'question_id': question.pk
            })
        # if QuestionAnswer.objects.filter(test_exam=test_exam, question=question).exists():
        #     raise serializers.ValidationError({
        #         'question': 'Question %s Exist for %s' % (question.pk, test_exam.pk),
        #         'exam': 'Exam %s Exist for %s' % (test_exam.pk, question.pk),
        #         'question_id': question.pk
        #     })

        return attrs

    def create(self, validated_data):
        test_exam = validated_data.get('test_exam')
        question = validated_data.get('question')
        answers = validated_data.get('answers')
        qs_answer, created = QuestionAnswer.objects.update_or_create(test_exam=test_exam, question=question, )
        qs_answer.answers.set(answers)
        # return super(QuestionAnswerSubmitSerializer, self).create(validated_data)
        return qs_answer
