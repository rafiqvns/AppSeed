# Generated by Django 2.2.24 on 2021-10-06 20:39

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('csd_quizes', '0005_auto_20211007_0237'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='questionchoice',
            options={'ordering': ('question__position', 'position'), 'verbose_name': 'Question Choice', 'verbose_name_plural': 'Question Choices'},
        ),
    ]
