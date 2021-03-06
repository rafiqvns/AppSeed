# Generated by Django 2.2.19 on 2021-03-11 09:46

from django.db import migrations, models
import safe_driver.image_functions


class Migration(migrations.Migration):

    dependencies = [
        ('safe_driver', '0018_auto_20210311_1015'),
    ]

    operations = [
        migrations.AddField(
            model_name='vehicleroadtest',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='btwbus',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='btwbus',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='btwbus',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassa',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassa',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassa',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassb',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassb',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassb',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassc',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassc',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='btwclassc',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='passengervehicles',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='passengervehicles',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='passengervehicles',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='pretripbus',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripbus',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripbus',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassa',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassa',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassa',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassb',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassb',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassb',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassc',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassc',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='pretripclassc',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='safedriveprod',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='safedriveprod',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='safedriveprod',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder),
        ),
        migrations.AlterField(
            model_name='safedriveswp',
            name='company_rep_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Company Rep Signature'),
        ),
        migrations.AlterField(
            model_name='safedriveswp',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='safedriveswp',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
        migrations.AlterField(
            model_name='vehicleroadtest',
            name='driver_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Driver Signature'),
        ),
        migrations.AlterField(
            model_name='vehicleroadtest',
            name='evaluator_signature',
            field=models.ImageField(blank=True, default=None, null=True, upload_to=safe_driver.image_functions.signature_image_folder, verbose_name='Evaluator Signature'),
        ),
    ]
