# Generated by Django 2.2.19 on 2021-08-24 23:25

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('truck_driving_school', '0009_dqfrequirement_schoolcontroldqfrequirement'),
    ]

    operations = [
        migrations.RenameField(
            model_name='schoolcontroldqfrequirement',
            old_name='intials',
            new_name='initials',
        ),
    ]