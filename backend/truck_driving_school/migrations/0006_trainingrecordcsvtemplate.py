# Generated by Django 2.2.19 on 2021-08-23 20:46

from django.db import migrations, models
import django.db.models.deletion
import truck_driving_school.models


class Migration(migrations.Migration):

    dependencies = [
        ('safe_driver', '0060_auto_20210815_0535'),
        ('truck_driving_school', '0005_auto_20210727_1824'),
    ]

    operations = [
        migrations.CreateModel(
            name='TrainingRecordCSVTemplate',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('csv_file', models.FileField(upload_to=truck_driving_school.models.csv_template_file_upload_path)),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('company', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='training_record_csv', to='safe_driver.Company')),
            ],
            options={
                'verbose_name': 'Training Record CSV Template',
                'verbose_name_plural': 'Training Record CSV Templates',
                'ordering': ('-company__name',),
            },
        ),
    ]
