/**
 * # Experiment
 *
 * This is the base datum for experiments, storing the base definition.
 *
 * This class should be subclassed for producing actual experiments. The
 * proc stubs should be implemented in whole.
 */
/datum/experiment
	/// Name that distinguishes the experiment
	var/name = "Experiment"
	/// A brief description of the experiment to be shown as details
	var/description = "Base experiment"
	/// A descriptive tag used on UI elements to denote 'types' of experiments
	var/exp_tag = "Base"
	/// A list of types that are allowed to experiment with this dastum
	var/list/allowed_experimentors
	/// Whether the experiment has been completed
	var/completed = FALSE
	/// Traits related to the experiment
	var/traits
	/// A textual hint shown on the UI in a tooltip to help a user determine how to perform
	/// the experiment
	var/performance_hint

/**
 * Performs any necessary initialization of tags and other variables
 */
/datum/experiment/New()
	if (traits & EXPERIMENT_TRAIT_DESTRUCTIVE)
		exp_tag = "Destructive [exp_tag]"

/**
 * Checks if the experiment is complete
 *
 * This proc should be overridden such that it returns TRUE/FALSE to
 * state if the experiment is complete or not.
 */
/datum/experiment/proc/is_complete()
	return

/**
 * Gets the current progress towards the goal of the experiment
 *
 * This proc should be overridden such that the return value is a
 * list of lists, wherein each inner list represents a stage. Stages have
 * types, see _DEFINES/experisci.dm. Each stage should be constructed using
 * one of several available macros in that file.
 */
/datum/experiment/proc/check_progress()
	. = list()

/**
 * Gets if the experiment is actionable provided some arguments
 *
 * This proc should be overridden such that the return value is a
 * boolean value representing if the experiment could be actioned with
 * the provided arguments.
 */
/datum/experiment/proc/actionable(...)
	return !is_complete()

/**
 * Proc that tries to perform the experiment, and then checks if its completed.
 */
/datum/experiment/proc/perform_experiment(datum/component/experiment_handler/experiment_handler, ...)
	var/action_succesful = perform_experiment_actions(arglist(args))
	if(is_complete())
		finish_experiment(experiment_handler)
	return action_succesful

/**
 * Attempts to perform the experiment provided some arguments
 *
 * This proc should be overridden such that the experiment will be actioned
 * with some defined arguments
 */
/datum/experiment/proc/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, ...)
	return

/**
 * Called when you complete an experiment, makes sure the techwebs knows the experiment was finished, and tells everyone it happend, yay!
 */
/datum/experiment/proc/finish_experiment(datum/component/experiment_handler/experiment_handler)
	completed = TRUE
	experiment_handler.announce_message_to_all("[name] успешно произведен!")
	experiment_handler.selected_experiment = null
	experiment_handler.linked_web.complete_experiment(src)
