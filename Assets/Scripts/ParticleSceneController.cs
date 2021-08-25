using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ParticleSceneController : MonoBehaviour
{
    public Animator animatorNaked;
    public Animator animatorDressed;
    public GameObject legsNaked;
    public GameObject bodyNaked;
    public GameObject legsDressed;
    public GameObject bodyDressed;
    public GameObject eyesDressed;
    public GameObject particles;
    public Button btnChange;
    private bool isClothed = false;

    private void Start()
    {        
        legsNaked.SetActive(true);
        bodyNaked.SetActive(true);
        legsDressed.SetActive(false);
        bodyDressed.SetActive(false);
        eyesDressed.SetActive(false);
        particles.SetActive(false);
    }

    public void ChangeClothes()
    {
        StartCoroutine(AnimationTimer());        
    }

    private void StartClothesChange()
    {
        animatorNaked.SetTrigger("StartChanging");
        animatorDressed.SetTrigger("StartChanging");
        particles.SetActive(true);
        btnChange.interactable = false;
    }

    private void PlayRandomAnimation()
    {
        int randomNumber = Random.Range(0, 4);
        animatorNaked.SetInteger("AnimationIndex", randomNumber);
        animatorDressed.SetInteger("AnimationIndex", randomNumber);
        animatorNaked.SetTrigger("Changing");
        animatorDressed.SetTrigger("Changing");

        if (!isClothed)
        {
            legsNaked.SetActive(false);
            bodyNaked.SetActive(false);
            legsDressed.SetActive(true);
            bodyDressed.SetActive(true);
            eyesDressed.SetActive(true);
            isClothed = true;
        }
        else
        {
            legsNaked.SetActive(true);
            bodyNaked.SetActive(true);
            legsDressed.SetActive(false);
            bodyDressed.SetActive(false);
            eyesDressed.SetActive(false);
            isClothed = false;
        }
    }

    IEnumerator AnimationTimer()
    {
        StartClothesChange();
        yield return new WaitForSeconds(0.5f);
        PlayRandomAnimation();
        yield return new WaitForSeconds(1f);
        particles.SetActive(false);
        btnChange.interactable = true;
    }
}
