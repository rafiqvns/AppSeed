# Generated by Django 2.2.19 on 2021-06-16 02:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('csd_quizes', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='position',
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.AddField(
            model_name='questionchoice',
            name='position',
            field=models.PositiveIntegerField(default=0),
        ),
    ]
