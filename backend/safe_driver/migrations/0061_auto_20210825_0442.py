# Generated by Django 2.2.19 on 2021-08-24 22:42

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('safe_driver', '0060_auto_20210815_0535'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='btwbrakesandstoppingsclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwcabsafetyclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwclassd',
            name='test',
        ),
        migrations.RemoveField(
            model_name='btwclutchandtransmissionclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwcouplingclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwengineoperationclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btweyemovementandmirrorclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwgeneralsafetyanddotadherenceclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwhillsclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwintersectionsclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwlightsandsignalsclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwmultipletrailersclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwparkingclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwpassingclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwrecognizeshazardsclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwspeedclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwstartengineclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwsteeringclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwturningclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='btwuncouplingclassd',
            name='btw',
        ),
        migrations.RemoveField(
            model_name='pretripbothsidesvehiclesclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripclassd',
            name='test',
        ),
        migrations.RemoveField(
            model_name='pretripcoalsclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripdollyclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripdriversidetrailerboxclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripenginecompartmentclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripfronttrailerboxclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripinsidecabclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretrippassengersidetrailerboxclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripposttripclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripreartrailerboxclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripvehiclefrontclassd',
            name='pre_trip_class_d',
        ),
        migrations.RemoveField(
            model_name='pretripvehicleortractorrearclassd',
            name='pre_trip_class_d',
        ),
        migrations.AlterField(
            model_name='btwbrakesandstoppingsclassp',
            name='btw',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_brakes_and_stopping_class_p', to='safe_driver.BTWClassP'),
        ),
        migrations.DeleteModel(
            name='BTWBackingClassD',
        ),
        migrations.DeleteModel(
            name='BTWBrakesAndStoppingsClassD',
        ),
        migrations.DeleteModel(
            name='BTWCabSafetyClassD',
        ),
        migrations.DeleteModel(
            name='BTWClassD',
        ),
        migrations.DeleteModel(
            name='BTWClutchAndTransmissionClassD',
        ),
        migrations.DeleteModel(
            name='BTWCouplingClassD',
        ),
        migrations.DeleteModel(
            name='BTWEngineOperationClassD',
        ),
        migrations.DeleteModel(
            name='BTWEyeMovementAndMirrorClassD',
        ),
        migrations.DeleteModel(
            name='BTWGeneralSafetyAndDOTAdherenceClassD',
        ),
        migrations.DeleteModel(
            name='BTWHillsClassD',
        ),
        migrations.DeleteModel(
            name='BTWIntersectionsClassD',
        ),
        migrations.DeleteModel(
            name='BTWLightsAndSignalsClassD',
        ),
        migrations.DeleteModel(
            name='BTWMultipleTrailersClassD',
        ),
        migrations.DeleteModel(
            name='BTWParkingClassD',
        ),
        migrations.DeleteModel(
            name='BTWPassingClassD',
        ),
        migrations.DeleteModel(
            name='BTWRecognizesHazardsClassD',
        ),
        migrations.DeleteModel(
            name='BTWSpeedClassD',
        ),
        migrations.DeleteModel(
            name='BTWStartEngineClassD',
        ),
        migrations.DeleteModel(
            name='BTWSteeringClassD',
        ),
        migrations.DeleteModel(
            name='BTWTurningClassD',
        ),
        migrations.DeleteModel(
            name='BTWUncouplingClassD',
        ),
        migrations.DeleteModel(
            name='PreTripBothSidesVehiclesClassD',
        ),
        migrations.DeleteModel(
            name='PreTripClassD',
        ),
        migrations.DeleteModel(
            name='PreTripCOALSClassD',
        ),
        migrations.DeleteModel(
            name='PreTripDollyClassD',
        ),
        migrations.DeleteModel(
            name='PreTripDriverSideTrailerBoxClassD',
        ),
        migrations.DeleteModel(
            name='PreTripEngineCompartmentClassD',
        ),
        migrations.DeleteModel(
            name='PreTripFrontTrailerBoxClassD',
        ),
        migrations.DeleteModel(
            name='PreTripInsideCabClassD',
        ),
        migrations.DeleteModel(
            name='PreTripPassengerSideTrailerBoxClassD',
        ),
        migrations.DeleteModel(
            name='PreTripPostTripClassD',
        ),
        migrations.DeleteModel(
            name='PreTripRearTrailerBoxClassD',
        ),
        migrations.DeleteModel(
            name='PreTripVehicleFrontClassD',
        ),
        migrations.DeleteModel(
            name='PreTripVehicleOrTractorRearClassD',
        ),
    ]
