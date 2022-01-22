# Generated by Django 2.2.19 on 2021-08-24 23:22

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('safe_driver', '0061_auto_20210825_0442'),
        ('truck_driving_school', '0008_auto_20210825_0454'),
    ]

    operations = [
        migrations.CreateModel(
            name='DQFRequirement',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=250, verbose_name='title')),
                ('department', models.CharField(choices=[('hr', 'HR'), ('trainer', 'Trainer')], max_length=10, verbose_name='Department')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
            ],
            options={
                'verbose_name': 'DQF Requirement',
                'verbose_name_plural': 'DQF Requirements',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='SchoolControlDQFRequirement',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('intials', models.CharField(blank=True, default=None, max_length=150, null=True, verbose_name='Intials')),
                ('date', models.DateField(blank=True, default=None, null=True)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('dqf_requirement', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='truck_driving_school.DQFRequirement')),
                ('test', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='school_control_dqf_requirement', to='safe_driver.StudentTest')),
            ],
            options={
                'verbose_name': 'School Control DQF Requirement',
                'verbose_name_plural': 'School Control DQF Requirements',
                'ordering': ('-created',),
            },
        ),
    ]
